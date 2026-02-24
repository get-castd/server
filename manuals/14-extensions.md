# Extensions

Lua extensions add server-side business logic to CASTD. While CAST
templates handle rendering and persistence declaratively, extensions
handle everything that needs imperative code: discounts, workflows,
integrations, audit trails.

**Language:** Lua 5.4 (sandboxed)
**Namespace:** `cn.*` — bridges into the CASTD kernel

---

## Why Lua

One binary, zero external interpreters. Lua 5.4 compiles into the CASTD
binary alongside SQLite — no runtime dependencies, no PATH lookups, no
version conflicts. Extensions load once at startup and execute in
microseconds.

---

## Extension Structure

Extensions live in `workspace/{bundle}/extensions/`:

```
extensions/
├── discount/
│   ├── init.lua          # Entry point (required)
│   └── rules.lua         # Additional module (loaded via require)
├── audit/
│   └── init.lua
└── newsletter.lua        # Single-file extension (legacy)
```

### Subfolder vs Single File

| Structure | require() | Use when |
|-----------|-----------|----------|
| `name/init.lua` | Available | Extension has multiple files |
| `name.lua` | Not available | Simple, self-contained logic |

### Enabling Extensions

In `server.toml`:

```toml
[extensions]
enabled = ["discount", "audit", "newsletter"]
timeout_ms = 100
```

Extensions load in the order listed. Order matters for event hooks.

---

## Extension Functions

An extension exports functions by defining them at top level:

```lua
-- discount/init.lua

function fn(args)
    local price = tonumber(args.price) or 0
    local code = args.code or ""
    
    if code == "SUMMER25" then
        return tostring(price * 0.75)
    end
    return tostring(price)
end
```

### Three Function Types

| Function | Called by | Purpose |
|----------|----------|---------|
| `fn(args)` | `{( cnx:name[key=value] )}` in templates | Inline computation |
| `route()` | Matched URL route | Full request handling |
| `api(args)` | `{! api cnx:name !}` blocks | Data fetching |

An extension may export any combination of these.

---

## The cn.* Namespace

Extensions access CASTD via the `cn` table:

### cn.db — Database

```lua
-- Insert a record, returns the new ID
local id = cn.db.set("products", {
    name = "Widget",
    price = "9.99"
})

-- Query records (omit second argument to get all)
local products = cn.db.get("products", { category = "tools" })
for _, p in ipairs(products) do
    cn.log.info(p.name .. ": " .. p.price)
end

-- Update records matching a condition, returns affected count
cn.db.update("products", { id = "1" }, { price = "8.99" })

-- Delete records matching a condition, returns affected count
cn.db.delete("products", { id = "1" })
```

`cn.db` also provides `backup()`, `export()`, and `import()` for data
management — see [11-persistence.md](11-persistence.md) for details.

### cn.log — Logging

```lua
cn.log.info("Order placed: " .. order_id)
cn.log.warn("Stock low: " .. product_name)
cn.log.error("Payment failed: " .. reason)
cn.log.debug("Cache hit for key: " .. key)
```

### cn.format — Formatting

```lua
cn.format.number(42.5, 2)           -- "42.50"
cn.format.currency(19.99, "GBP")    -- "£19.99"
cn.format.date(1700000000, "%d.%m.%Y")  -- "14.11.2023"
```

### cn.req — Request (read-only)

```lua
local path = cn.req.path
local method = cn.req.method
local token = cn.req.headers["Authorization"]
local page = cn.req.query["page"]
local body = cn.req.body
```

### cn.res — Response

```lua
cn.res.status(201)
cn.res.header("X-Custom", "value")
cn.res.body("Created")
cn.res.redirect("/success")
cn.res.json({ success = true, id = 42 })
```

### cn.auth — Authentication

```lua
local user = cn.auth.user    -- nil if not logged in
local role = cn.auth.role    -- "guest", "user", "editor", "admin"

local result = cn.auth.login("user@example.com", "password")
if result.success then
    cn.log.info("Logged in: " .. result.user.email)
end

cn.auth.logout()
```

### cn.crypto — Cryptography

```lua
local hash = cn.crypto.hash("secret")
local valid = cn.crypto.verify("secret", hash)
local token = cn.crypto.token()
```

### cn.mail — Email

Send plaintext email via the configured SMTP server.

```lua
local result = cn.mail.send("recipient@example.com", "Subject", "Body text")
if result.success then
    cn.log.info("Sent: " .. result.message_id)
else
    cn.log.error("Mail failed: " .. result.error)
end

-- With Reply-To (e.g. contact form):
local result = cn.mail.send(
    "admin@example.com",
    "[Contact] Question",
    "Message body",
    "visitor@example.com"    -- optional: Reply-To header
)
```

The fourth parameter is optional. When provided, replies in the
recipient's mail client will be addressed to the reply-to address
rather than the `from` address configured in `server.toml`.

Returns a table:

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether the message was accepted by the SMTP server |
| `message_id` | string | Server-assigned message ID (only on success) |
| `error` | string | Error description (only on failure) |

#### Configuration

Requires a `[mail]` section in `server.toml`:

```toml
[mail]
from = "noreply@example.com"
smtp_host = "localhost"
smtp_port = 25
# smtp_user = ""
# smtp_pass = ""
# smtp_tls = false
```

| Key | Default | Description |
|-----|---------|-------------|
| `from` | — | Sender address (required — mail is disabled without it) |
| `smtp_host` | `localhost` | SMTP server hostname |
| `smtp_port` | `25` | SMTP server port |
| `smtp_user` | — | Username for authenticated relays |
| `smtp_pass` | — | Password for authenticated relays |
| `smtp_tls` | `false` | Use STARTTLS |

When `from` is not set, `cn.mail.send()` returns
`{success = false, error = "Mail not configured"}` without attempting a
connection.

#### Rate Limiting

Mail sending is limited to `extensions.max_mail_per_min` (default: 10).
The counter is global — shared across all extensions and requests.

---

## Event Hooks

Extensions can react to database changes by defining hook functions.
Hooks fire after successful `cn.db` mutations — useful for audit logging,
cache invalidation, notifications, and similar patterns.

### Three Hook Types

| Function | Fires after | Arguments |
|----------|-------------|-----------|
| `on_write(table, id, fields)` | `cn.db.set()` | table name, new row ID (integer), field data (table) |
| `on_update(table, ids, fields)` | `cn.db.update()` | table name, affected IDs (array), updated fields (table) |
| `on_delete(table, ids)` | `cn.db.delete()` | table name, deleted IDs (array) |

### Example: Audit Log

```lua
-- audit/init.lua

function on_write(tbl, id, fields)
    cn.db.set("audit_log", {
        event = "write",
        target_table = tbl,
        target_id = tostring(id),
        timestamp = tostring(os.time and os.time() or 0)
    })
end

function on_update(tbl, ids, fields)
    cn.db.set("audit_log", {
        event = "update",
        target_table = tbl,
        count = tostring(#ids)
    })
end

function on_delete(tbl, ids)
    cn.db.set("audit_log", {
        event = "delete",
        target_table = tbl,
        count = tostring(#ids)
    })
end
```

### Behaviour

- **Error tolerance:** A hook error never fails the original database
  operation. Errors are logged to stderr and execution continues.
- **Recursion prevention:** If `on_write` calls `cn.db.set()`, the write
  succeeds but does not re-trigger `on_write` hooks. Cross-event calls
  are permitted: `on_delete` may call `cn.db.set()` and `on_write` will
  fire for that write.
- **Execution order:** Hooks fire in the order extensions are listed in
  `server.toml`.
- **Timeout:** Hooks have a 5-second timeout (vs 100 ms for `fn`/`route`/`api`).

---

## Client Detection

On first visit, CASTD serves a lightweight detection page that collects
the client's viewport dimensions, device pixel ratio, touch capability,
and preferred language. This data is stored in a cookie (`castd_client`)
and available in templates as `client.*` variables.

### Template Variables

| Variable | Type | Example | Description |
|----------|------|---------|-------------|
| `client.viewport_width` | Number | `1440` | CSS viewport width |
| `client.viewport_height` | Number | `900` | CSS viewport height |
| `client.screen_width` | Number | `2560` | Physical screen width |
| `client.screen_height` | Number | `1440` | Physical screen height |
| `client.dpr` | Number | `2` | Device pixel ratio |
| `client.touch` | Boolean | `false` | Touch capability |
| `client.lang` | String | `"en-GB"` | Browser language |
| `client.device` | String | `"desktop"` | Inferred device type |
| `client.breakpoint` | String | `"wide"` | CSS breakpoint category |
| `client.bot` | Boolean | `false` | Search engine crawler |

### Device Types

| Device | Condition |
|--------|-----------|
| `phone` | Viewport < 560 px and touch |
| `tablet` | Viewport < 960 px and touch |
| `desktop` | Everything else |
| `bot` | Detected via User-Agent |

### Breakpoints

| Breakpoint | Viewport width |
|------------|---------------|
| `phone` | < 560 px |
| `tablet` | 560–959 px |
| `screen` | 960–1259 px |
| `wide` | >= 1260 px |

### Usage in Templates

```html
{# if client.device = "phone" #}
    <p>Mobile layout</p>
{# elseif client.device = "tablet" #}
    <p>Tablet layout</p>
{# else #}
    <p>Desktop layout</p>
{# endif #}

{# if client.touch #}
    <button class="use-large-touch-target">Tap here</button>
{# endif #}
```

### Bot Handling

Search engine crawlers receive default desktop values (1920x1080) without
the detection page. No cookie is set for bots.

---

## Sandbox

Extensions run in a restricted Lua environment. The following standard
library modules are blocked:

| Blocked | Reason |
|---------|--------|
| `os` | No shell access |
| `io` | No filesystem access |
| `require` | Only within extension subfolder |
| `dofile`, `loadfile`, `load` | No arbitrary code loading |
| `package` | No external modules |

Available: `string`, `table`, `math`, `pairs`, `ipairs`, `type`,
`tonumber`, `tostring`, `pcall`, `xpcall`, `error`, `select`, `unpack`.

---

## Limits

| Limit | Default | Config key |
|-------|---------|------------|
| Execution timeout | 100 ms | `extensions.timeout_ms` |
| Hook timeout | 5000 ms | — |
| Memory | 16 MB | `extensions.memory_mb` |
| DB writes per request | 100 | `extensions.max_db_writes` |
| Emails per minute | 10 | `extensions.max_mail_per_min` |

---

## See Also

- [05-cast-reference.md](05-cast-reference.md) — Extension call syntax `{( cnx:name )}`
- [11-persistence.md](11-persistence.md) — CAST-side database operations
- [08-scripting.md](08-scripting.md) — Client-side `cn.*` namespace

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
