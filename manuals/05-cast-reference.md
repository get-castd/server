# CAST — Language Reference

> **CAST** (Content & Structure Templating): A server-side template language
> with five syntax types and an integrated persistence layer.

This document is the single authoritative reference for CAST syntax. It is
written for both human developers and language models. Every construct is
defined once, with its exact notation, rules, and a minimal example.

---

## Table of Contents

1. [Architecture](#architecture)
2. [Syntax Overview](#syntax-overview)
3. [Data — `{{ }}`](#data)
4. [Logic — `{! !}`](#logic)
5. [Presets — `{( )}`](#presets)
6. [Persistence — `{* *}`](#persistence)
7. [Comments — `{# #}`](#comments)
8. [Extensions](#extensions)
9. [Modifiers](#modifiers)
10. [Constants](#constants)
11. [Naming Conventions](#naming-conventions)
12. [Configuration](#configuration)

---

## Architecture

```
Request → Extensions (Lua) → Parser → Renderer → HTML Response
               │                 │
               ▼                 ├────────────────────┐
           Context               ▼                    ▼
                             Templates             Presets
                            (workspace)    (framework + workspace)
```

**Directory layout:**

```
{project}/
├── castd/               ### Framework (DO NOT MODIFY)
│   ├── backend/
│   │   ├── bin/              ### Server binary (platform-specific)
│   │   └── extensions/       ### Lua extensions (sample: currency_convert)
│   ├── frontend/
│   │   ├── assets/{scripts,styles,images}/
│   │   └── presets/{components,extensions,themes}/
│   └── server.default.toml   ### Predefined project config, cp to server.toml for individual use
├── workspace/{bundle}/   ### Your content bundled
│   ├── assets/{scripts,styles,images}/
│   ├── presets/{components,extensions,themes}/
│   ├── templates/
│   └── bundle.toml       ### Your bundle config
└── manuals/
```

**Naming convention:** Every file is named after its containing folder.
`button/button.html`, not `button/index.html`.

---

## Syntax Overview

CAST uses five delimiter pairs. Each has a distinct purpose.
Whitespace inside delimiters is flexible and trimmed.

| Delimiter | Purpose | Mnemonic |
|-----------|---------|----------|
| `{{ }}` | Data output and assignment | "Curly = value" |
| `{! !}` | Logic and control flow | "Bang = action" |
| `{( )}` | Preset insertion | "Parens = component" |
| `{* *}` | Persistence operations | "Star = storage" |
| `{# #}` | Comments (stripped) | "Hash = hidden" |

---

## Data

**Purpose:** Output variables, assign values, apply modifiers.

> **Concept:** All output is HTML-escaped by default. This prevents XSS
> without requiring the developer to think about it. Use `| raw` only when
> you explicitly trust the content. Modifiers are pure transforms — they
> never mutate the source variable, only the output.

### Variable Output

```
{{ name }}
```

Outputs the value of `name`, HTML-escaped by default.

```
{{ product.title }}              Nested property
{{ items[0] }}                   Array index (literal)
{{ items[index] }}               Array index (variable)
```

### Modifiers

Modifiers transform output. Chain with `|`. Evaluated left to right.

```
{{ name | upper }}               HELLO
{{ name | lower }}               hello
{{ name | trim }}                Remove leading/trailing whitespace
{{ name | length }}              Character count (string) or item count (array)
{{ name | truncate=100 }}        Cut at 100 characters
{{ name | slug }}                hello-world
{{ name | escape }}              &lt;b&gt; (HTML entities)
{{ name | raw }}                 Skip HTML escaping (output as-is)
{{ name | default="N/A" }}       Fallback when empty/null
{{ name | translate }}           i18n lookup from CSV
{{ name | upper | truncate=5 }} Chain: uppercase then truncate
```

### Assignment

```
{{ title = "Hello" }}            String literal
{{ count = 42 }}                 Number literal
{{ active = true }}              Boolean literal
{{ copy = original }}            Variable reference
{{ copy = original | upper }}    With modifier
```

**List literal:**

```
{{ items = ["apple", "banana", "cherry"] }}
{{ mixed = ["text", 42, true] }}
{{ empty = [] }}
{{ with_ref = ["fixed", some_variable] }}
```

Elements may be strings, numbers, booleans, or variable references.
Lists support `| length`, `{! each !}`, and index access `{{ items[0] }}`.

**Object literal:**

```
{{ config = {title: "Hello", count: 42} }}
{{ product = {name: "Widget", price: 9.99, active: true} }}
{{ dynamic = {label: some_variable} }}
{{ empty = {} }}
```

Keys are unquoted identifiers. Values may be strings, numbers, booleans,
or variable references. Access properties with dot notation: `{{ config.title }}`.

Assignments produce no output. They set context variables for the template.

### String Literals

Both quote styles are equivalent:

```
{{ "double" }}
{{ 'single' }}
```

---

## Logic

**Purpose:** Control flow, loops, reactivity, real-time connections.

> **Concept:** Logic blocks are intentionally simple. No `&&`, `||`, or
> ternary operators. Complex conditions are expressed through nesting — each
> `{! if !}` tests one thing. This keeps the parser minimal and templates
> readable. If your logic becomes complex, move it to a Lua extension (see
> [Extensions](#extensions)) where you have full procedural control.

### Conditionals

```
{! if condition !}
  Rendered when truthy.
{! endif !}
```

**Truthy:** Non-empty string, non-zero number, `true`.
**Falsy:** Empty string `""`, `0`, `false`, `null`, undefined.

**Comparison operators:**

```
{! if x == y !}                  Equal
{! if x != y !}                  Not equal
{! if x > y !}                   Greater than
{! if x < y !}                   Less than
{! if x >= y !}                  Greater or equal
{! if x <= y !}                  Less or equal
{! if lang == "en-GB" !}         String comparison
```

**Else and elseif branches:**

```
{! if role == "admin" !}
  Full access.
{! elseif role == "editor" !}
  Edit access.
{! else !}
  Read-only access.
{! endif !}
```

Branches are evaluated in order. The first matching condition renders; others
are skipped. `else` has no condition and matches if nothing else did.

**Nesting:**

```
{! if user !}
  {! if user.role == "admin" !}
    Admin content.
  {! endif !}
{! endif !}
```

### Loops

```
{! each items !}
  {{ item }}                     Current element
  {{ index }}                    0-based position
{! endeach !}
```

`item` and `index` are implicit loop variables. Nested property access:

```
{! each products !}
  {{ item.name }}: {{ item.price }}
{! endeach !}
```

### API Connections (Reactivity)

Connect a template region to a Lua extension for live data updates. The extension
name references a file in `backend/extensions/` — no URLs are exposed in templates.

```
{! api extension_name | websocket !}
  {{ data }}
{! endapi !}
```

**Transport modifiers (mutually exclusive):**

| Modifier | Behaviour |
|----------|-----------|
| `websocket` | Bidirectional, persistent connection (default) |
| `sse` | Server-Sent Events, unidirectional |
| `fetch` | Single Fetch request |

**Additional modifiers:**

| Modifier | Value | Effect |
|----------|-------|--------|
| `poll` | Milliseconds | Repeat fetch at interval |
| `debug` | — | Log to browser console |

```
{! api stock_feed | sse !}
  {{ product.price }}
{! endapi !}

{! api stats | fetch & poll=5000 !}
  {{ visitors }}
{! endapi !}

{! api stock_feed | websocket & debug !}
  {{ product.stock }}
{! endapi !}
```

`&` separates multiple modifiers.

> **Concept:** API blocks reference extension names, not URLs. The server resolves
> the extension from `backend/extensions/` and calls its `function api()`. This keeps
> endpoints out of the HTML source and centralises routing in `server.toml`.

### Bind Blocks (Client Reactivity)

Mark a region for client-side re-rendering when a variable changes.

```
{! bind product.stock !}
  <span>{{ product.stock }} in stock</span>
{! endbind !}
```

Multiple variables (comma-separated):

```
{! bind cart.items, cart.total !}
  {{ cart.items | length }} items — {{ cart.total }}
{! endbind !}
```

Bind blocks generate a `<div>` wrapper with a unique ID and register
with the client-side data bus for `cn:update` events.

> **Concept:** API and bind are decoupled. The variable name is the channel.
> An API block writes variables to the client bus, firing `cn:update` events.
> Every bind block listening to those names re-renders automatically. They need
> not be adjacent or nested — they can appear anywhere on the page. Multiple
> bind blocks may react to the same variable. If two APIs would collide on the
> same name, use distinct names in the backend extension.
>
> ```
> {! api stock_feed | websocket !}{! endapi !}
>
> {! bind product.stock !}
>   <span>{{ product.stock }} available</span>
> {! endbind !}
>
> {! bind product.price !}
>   <span>{{ product.price }}</span>
> {! endbind !}
> ```

### Slots (Template Inheritance)

> **Concept:** Slots provide a universal mechanism for partial content
> replacement. A slot is a named region with default content. Child
> templates (via `{! extends !}`) or preset consumers (via `| slotlist`)
> can override individual slots without replacing the entire file. This
> serves two purposes: template inheritance (avoiding boilerplate) and
> preset customisation (replacing parts of a component).

Define a replaceable region:

```
{( slot name )}
  Default content (used when not overridden)
{( endslot )}
```

**Template inheritance** — extend a base template, override specific slots:

```
{# _base.html #}
<!doctype html>
<html lang="en-GB">
<head>
    <title>{( slot title )}Default{( endslot )}</title>
</head>
<body>
    {( slot content )}{( endslot )}
</body>
</html>
```

```
{# home.html — inherits from _base.html #}
{! extends "_base.html" | slotlist !}

{( slot title )}Home — CASTD{( endslot )}

{( slot content )}
<h1>Welcome</h1>
{( endslot )}
```

**Two modes:**

| Mode | Syntax | Behaviour |
|------|--------|-----------|
| **slotlist** | `{! extends "path" \| slotlist !}` | Only slot blocks allowed; unoverridden slots keep defaults |
| **full** | `{! extends "path" !}` | Child replaces entire base; slots ignored |

`full` is the default when no modifier is given.

**Inheritance chains** are supported: A extends B extends C. The server
resolves the chain recursively, processing extends declarations from the
innermost template outward.

**Preset slots** — override parts of a preset:

```
{( cn:preset.layout.header | slotlist )}
    {( slot logo )}
        <img src="/my-logo.svg" alt="My Brand">
    {( endslot )}
{( endpreset )}
```

**Rules:**
- `{! extends !}` must be the first meaningful token in the file.
- In slotlist mode, only `{( slot )}` blocks are permitted — no loose HTML.
- Unoverridden slots render their default content.
- An empty override (`{( slot x )}{( endslot )}`) produces no output.
- A slot in the child that does not exist in the base is silently ignored.

**Path resolution:**

```
{! extends "_base.html" !}        Relative to templates/ root
{! extends "../_base.html" !}     Relative to current file directory
```

---

## Presets

**Purpose:** Insert server-rendered components. Presets generate clean HTML
that `castd.css` styles directly.

> **Concept:** Presets are the component layer. They are rendered server-side
> on every request — no client-side hydration, no virtual DOM. A preset is
> simply an HTML fragment with optional CSS and JS. The framework resolves
> them by name, injects their assets once, and outputs clean markup. Bundle
> presets override framework presets, so customers can replace any component.

### Syntax

```
{( cn:preset.category.name )}
{( cn:preset.category.name["arg1", "arg2"] )}
{( cn:preset.category.name | modifier )}
{( cn:preset.category.name["arg1"] | modifier1 & modifier2 )}
```

### Positional Arguments

Passed in brackets. Mapped to `{{ 1 }}`, `{{ 2 }}`, etc. inside the preset template.

```
{( cn:preset.form.button["Submit"] )}
{( cn:preset.ui.card["Title", "Subtitle"] )}
```

### Named Attributes

Key-value pairs after the name, before the pipe.

```
{( cn:preset.form.input type="email" placeholder="Email" required )}
```

Boolean attributes (no value) are set to `true`.

### Modifiers

After the `|` pipe. Separate multiple with `&`.

```
{( cn:preset.form.button["Save"] | action="/api/save" )}
{( cn:preset.form.button["Save"] | action="/api/save" & loading="Saving..." )}
```

**Action modifiers:**

| Modifier | Value | Effect |
|----------|-------|--------|
| `action` | URL path | POST to endpoint on click |
| `data` | Variable | Send variable as payload |
| `loading` | Text | Replace label during request |
| `loading-class` | CSS class | Add class during request |
| `open` | Modal name | Open named modal on click |
| `close` | — | Close parent modal on click |

### Categories

| Prefix | Purpose | Examples |
|--------|---------|----------|
| `cn:preset.form.*` | Form elements | button, input, select, checkbox, radio, file, textarea, range, search, password |
| `cn:preset.ui.*` | Interface components | card, alert, dialog, tabs, accordion, badge, toast, dropdown, wizard |
| `cn:preset.layout.*` | Page structure | header, footer, nav, sidebar, grid, container, breadcrumb |

### Built-in Extensions

Extensions are presets that compute values rather than render HTML.

```
{( cn:preset.date )}                     Current date (default format)
{( cn:preset.date | YYYY-MM-DD )}        2026-01-24
{( cn:preset.date | DD.MM.YYYY )}        24.01.2026
{( cn:preset.date | unix )}              Unix timestamp

{( cn:preset.hash )}                     Random hash (default 16 chars)
{( cn:preset.hash | 8 )}                 8-character hash

{( cn:preset.uuid )}                     UUID v4
{( cn:preset.slug["Hello World!"] )}     hello-world
{( cn:preset.random[1, 100] )}           Random integer 1–100

{( cn:preset.docs["/readme.md"] )}       Import and render documentation
{( cn:preset.docs["/man/tar.1"] | toc )} With table of contents
{( cn:preset.docs["/spec.md"] | toc & format="md" )}  Explicit format + TOC
```

### Inline Preset Definition (Macros)

Define reusable fragments within a template:

```
{( preset entry[name, price] )}
  <div class="as-row">{{ name }}: {{ price }}</div>
{( endpreset )}

{( entry["Apple", "2.99"] )}
{( entry["Banana", "1.49"] )}
```

### Snippets

> **Concept:** Snippets solve the "show code and render it" problem. They
> define a fragment once and reference it by name — as rendered output, as
> a code example, or as a parameter to another preset. They are local to
> their template and never leak across files.

Snippets are named inline definitions for reuse within the same template.

**Definition** (no parameters):

```
{( cn:snippet.preview )}
<button class="as-button">Click</button>
{( endsnippet )}
```

**Call** (with parameters):

```
{( cn:snippet.preview[code="<input>"] )}
```

**As preset parameter:**

```
{( cn:snippet.demo )}
<p>Hello world</p>
{( endsnippet )}

{( cn:preset.docs.example[preview="cn:snippet.demo"] )}
```

**Rules:**
- No parameters = definition. With parameters = call.
- Snippets are local to their template (not shared across files).
- Snippet content is resolved when passed as a preset parameter value.

### Preset Slots

Override specific regions of a preset without replacing the entire template.
The preset defines named slots with `{( slot )}`, the consumer overrides them
via `| slotlist`.

**Preset definition (e.g. `header/header.html`):**

```
<header>
    {( slot logo )}
        <img src="/logo.svg" alt="CASTD">
    {( endslot )}
    <nav>
        {( slot nav )}
            <a href="/">Home</a>
        {( endslot )}
    </nav>
</header>
```

**Consumer override:**

```
{( cn:preset.layout.header | slotlist )}
    {( slot logo )}
        <img src="/my-logo.svg" alt="My Brand">
    {( endslot )}
{( endpreset )}
```

Only overridden slots change. The `nav` slot keeps its default content.

**Rules:**
- `| slotlist` modifier required on the preset call.
- Override block ends with `{( endpreset )}`.
- Content outside `{( slot )}` blocks in the override is ignored.
- An empty override (`{( slot x )}{( endslot )}`) produces no output.
- Without `| slotlist`, the preset renders normally with all default slots.

### Preset Resolution Order

1. Bundle presets: `workspace/{bundle}/presets/components/{category}/{name}/`
2. Framework presets: `castd/frontend/presets/components/{category}/{name}/`

Bundle presets override framework presets of the same name.

### Preset File Structure

Each preset is a folder containing up to three files:

```
form/button/
├── button.html              Template (required)
├── button.css               Styles (optional, injected into <head>)
└── button.js                Script (optional, injected before </body>)
```

CSS and JS are deduplicated: if a preset is called multiple times,
its assets are included only once.

---

## Persistence

**Purpose:** Database operations, authentication, access control, asset management.

> **Concept:** Persistence is declarative. You state what you want (read,
> write, update, delete) and the server handles SQL, validation, and
> transactions. There is no ORM, no model layer, no migration system.
> Tables and columns are created on first use. This is intentional — for
> content-driven sites, schema flexibility beats schema rigidity.

### Database: Read

```
{* read db.posts *}
  {! each items !}
    <h2>{{ item.title }}</h2>
  {! endeach !}
{* endread *}
```

**Query modifiers:**

| Modifier | Value | Effect |
|----------|-------|--------|
| `where` | `field=value` | Filter (multiple conditions with `,`) |
| `order` | `field [asc\|desc]` | Sort results |
| `limit` | Number | Maximum rows |
| `offset` | Number | Skip rows (pagination) |

```
{* read db.posts | where published=true, featured=true | order=created desc | limit=10 *}
```

The result set is available as `items` inside the block.

### Database: Write

```
{* write db.posts *}
  {{ title = form.title }}
  {{ slug = form.title | slug }}
  {{ author = user.id }}
  {{ published = now }}
{* endwrite *}
```

Creates a new record. Columns are created automatically if they do not exist.

### Database: Update

```
{* update db.posts | where id=route.id *}
  {{ title = form.title }}
  {{ updated = now }}
{* endupdate *}
```

### Database: Delete

```
{* delete db.posts | where id=route.id *}
```

Delete has no block — it is a single statement.

### Built-in Variables

| Variable | Source | Content |
|----------|--------|---------|
| `user` | Session | Current user object (or null) |
| `user.id` | Session | User ID |
| `user.email` | Session | Email address |
| `user.role` | Session | Role string |
| `form.*` | POST body | Submitted form data |
| `route.*` | URL | Path parameters |
| `now` | Server | Current timestamp |
| `redirect` | Assignment | Set to trigger redirect |

### Authentication

**Login:**

```
{* auth login *}
  {! if error !}<p>{{ error }}</p>{! endif !}
  {! if success !}{{ redirect = "/dashboard" }}{! endif !}
{* endauth *}
```

**Logout:**

```
{* auth logout *}
```

**Register:**

```
{* auth register | role="user" *}
  {! if success !}{{ redirect = "/welcome" }}{! endif !}
{* endauth *}
```

### Access Control (Require)

> **Concept:** Access control is declarative, not procedural. You wrap content
> in a require block and state the condition. The server evaluates it against
> the session. If it fails, the block is silently omitted — no redirect, no
> error page. This keeps templates clean and security explicit.

Guard content behind conditions:

```
{* require logged-in *}
  Welcome, {{ user.email }}.
{* endrequire *}

{* require logged-out *}
  <a href="/login">Sign in</a>
{* endrequire *}

{* require role="admin" *}
  Admin panel link.
{* endrequire *}

{* require permission="posts.write" *}
  <button>New Post</button>
{* endrequire *}
```

**Role hierarchy:** guest < user < editor < admin.
Higher roles inherit all permissions of lower roles.

**Default permissions:**

| Role | Permissions |
|------|-------------|
| guest | (none) |
| user | posts.read |
| editor | posts.read, posts.write, posts.delete |
| admin | (all) |

### Volumes (Digital Asset Management)

> **Concept:** Volumes abstract file storage. You define what types a volume
> accepts and what transforms it supports, then read/write/delete assets
> using the same `{* *}` syntax as database records. The server handles
> filesystem operations, image resizing, and optional token-secured URLs.

**Define a volume:**

```
{* volume "images" | path="/media/images", accept="jpg,png,webp", transforms="thumb:200x200, medium:800x600" *}
{* volume "docs" | path="/media/docs", accept="pdf,txt", secure *}
```

| Modifier | Value | Effect |
|----------|-------|--------|
| `path` | Directory | Storage location |
| `accept` | Extensions | Allowed file types (`*` = all) |
| `transforms` | `name:WxH` | Named image transforms |
| `secure` | — | Token-protected downloads |

**Read assets:**

```
{* read volume.images | limit=20 *}
  {! each items !}
    <img src="{{ item.url | transform=thumb }}" alt="{{ item.alt }}">
  {! endeach !}
{* endread *}
```

**Write (upload):**

```
{* write volume.images *}
  {( cn:preset.form.file | accept="image/*" )}
{* endwrite *}
```

**Asset properties:**

| Property | Type | Content |
|----------|------|---------|
| `item.id` | String | Unique asset identifier |
| `item.url` | String | Original URL |
| `item.filename` | String | File name |
| `item.type` | String | MIME type |
| `item.size` | Number | Bytes |
| `item.width` | Number | Pixels (images) |
| `item.height` | Number | Pixels (images) |
| `item.focal_x` | Number | Focal point 0–100 |
| `item.focal_y` | Number | Focal point 0–100 |
| `item.alt` | String | Alt text |
| `item.title` | String | Title |
| `item.created` | String | Upload timestamp |

**Transform modifier:**

```
{{ item.url | transform=thumb }}         Transformed URL
{{ item.url | secure }}                  Signed URL with token
```

---

## Comments

```
{# This is stripped from output. #}

{#
  Multi-line comments
  are also supported.
#}
```

Comments produce no output whatsoever. They are removed during parsing.

---

## Extensions

> **Concept:** Extensions are server-side Lua modules that extend CASTD
> without modifying its source. They provide a kernel-like architecture:
> the Rust binary is the kernel, Lua extensions are user-space modules. Extensions
> have access to `cn.*` functions but cannot access the filesystem, shell,
> or network directly. Lua was chosen for its tiny footprint (~200KB),
> battle-tested embedding story, and 30-minute learning curve.

### Terminology: Extension vs Helper

| Term | Definition |
|------|------------|
| **Extension** | Lua module that can provide various functionality (routes, APIs, helpers) |
| **Helper** | Frontend function callable in templates for calculations/formatting |

**Key insight:** An Extension can provide a Helper (via `function fn()`), but
not every Extension provides a Helper. Route extensions and API extensions
are NOT helpers — they serve different purposes.

| Extension Function | Purpose | Is it a Helper? |
|--------------------|---------|-----------------|
| `function route()` | Runs before template rendering | NO |
| `function api(args)` | Provides data for `{! api !}` blocks | NO |
| `function fn(args)` | Exposes a callable Helper for templates | **YES** |

**Helper types:**

| Type | Namespace | Implementation | Example |
|------|-----------|----------------|---------|
| cn:* Helper | `cn:*` | Rust (ours) | `cn.format.currency(19.99, "EUR")` |
| cnx:* Helper | `cnx:*` | Lua (user's, via `function fn()`) | `{( cnx:discount[price] )}` |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  castd Binary (Rust Kernel)                             │
│  ───────────────────────────────────────────────────────    │
│  cn.* Namespace (Rust functions)                            │
│  - Available to: Templates AND Lua extensions               │
│  ───────────────────────────────────────────────────────    │
│  Lua Sandbox Engine                                         │
│  - Timeout enforcement (kills hanging extensions)           │
│  - Memory limit (prevents memory bombs)                     │
│  - Only cn.* exposed, everything else blocked               │
│  - Cold-start capable: next request normal after crash      │
└─────────────────────────────────────────────────────────────┘
         │
         │ cn.* API (validated access)
         ▼
┌─────────────────────────────────────────────────────────────┐
│  cnx:* Extensions (Lua scripts, user extensions)           │
│  Location: castd/backend/extensions/                   │
│  Syntax: {( cnx:name[arg1, arg2] )}                        │
└─────────────────────────────────────────────────────────────┘
```

### Namespace Separation

| Namespace | Implementation | Purpose |
|-----------|----------------|---------|
| `cn.*` | Rust (in binary) | Core functions for templates + extensions |
| `cnx:*` | Lua (external files) | User extensions (called via `{( )}`) |

Both use the **Call syntax** `{( )}`:

```html
<!-- Core preset (Rust) -->
{( cn:preset.form.button["Submit"] )}

<!-- User extension (Lua) -->
{( cnx:currency_convert[price, "EUR", "USD"] )}

<!-- API call to Lua extension -->
{! api cnx:stock_feed[product_id, currency] !}
```

### Location

Extensions live in `castd/backend/extensions/`. Two file structures
are supported:

**Single-file** (simple extensions):
```
extensions/
├── discount.lua
└── checkout.lua
```

**Subfolder** (complex extensions with modules):
```
extensions/
└── currency_convert/
    ├── init.lua        ← Entry point (required)
    └── rates.lua       ← Local module
```

**Resolution order:** Subfolder (`{name}/init.lua`) is checked first, then
single-file (`{name}.lua`).

### Modularisation with require()

Subfolder extensions get a sandboxed `require()` function for loading local
modules. The sandbox ensures modules can only be loaded from within the
extension's own directory.

```lua
-- extensions/currency_convert/init.lua
local rates = require("rates")

function fn(args)
    local amount = tonumber(args["1"]) or 0
    local from = args["2"] or "EUR"
    local to = args["3"] or "EUR"
    return cn.format.currency(rates.convert(amount, from, to), to)
end
```

```lua
-- extensions/currency_convert/rates.lua
local M = {}

M.data = {
    EUR = 1.0,
    USD = 1.08,
    GBP = 0.86,
}

function M.convert(amount, from, to)
    local from_rate = M.data[from]
    local to_rate = M.data[to]
    if not from_rate or not to_rate then return nil end
    return amount / from_rate * to_rate
end

return M
```

**Security:** The sandboxed `require()` blocks:
- Path traversal (`../`, `..\\`)
- Absolute paths (`/`, `C:\`)
- Access outside the extension's subfolder

**Caching:** Required modules are cached per extension — repeated `require()`
calls return the cached result.

### Security Philosophy

**Principle:** Developer = adult. We protect the system, not the developer
from themselves.

| Category | Allowed | Rationale |
|----------|---------|-----------|
| Application data | ✅ | Their database, their problem |
| Sessions | ✅ | Their sessions, their problem |
| E-mails | ✅ | With rate limit |
| External APIs | ✅ | Only pre-configured endpoints |
| System access | ❌ | Protects the kernel |

**Blocked (system protection):**
- `os.*`, `io.*`, `dofile`, `loadfile` — no filesystem/shell access
- Global `require` — only sandboxed `require()` in subfolder extensions
- Infinite loops → timeout kills the extension
- Memory bombs → memory limit

### Defaults and Limits

Secure defaults are hardcoded in Rust. Developers can loosen them via
`server.toml` if they know what they're doing.

| Setting | Default | Description |
|---------|---------|-------------|
| `timeout_ms` | 100 | Max execution time per extension |
| `memory_mb` | 16 | Max memory per extension |
| `max_db_writes` | 100 | Max write operations per request |
| `max_mail_per_min` | 10 | Rate limit for e-mail sending |

**Customisation (optional):**

```toml
[extensions]
timeout_ms = 500          # Increased from 100
memory_mb = 32            # Increased from 16
max_mail_per_min = 50     # Increased from 10
```

Missing entries use defaults.

### Activation

Extensions must be explicitly enabled:

```toml
[extensions]
enabled = ["currency_convert", "discount", "checkout"]
```

Only enabled extensions are loaded. A `.lua` file without an entry in `enabled`
is ignored.

### Cold-Start Behaviour

Extensions are resilient by design:

1. Extension loaded at server start
2. Request arrives
3. Extension executes
4. **If timeout/crash:** Extension killed, request continues without result
5. **Next request:** Extension reloaded automatically (cold-start)

No manual intervention required. The kernel (server) always keeps running.

### Sandbox — The `cn.*` Namespace

Extensions have access to exactly nine keywords plus a sandboxed `require()`
for subfolder extensions. Nothing else exists in the sandbox — no `os`, no
`io`, no global `require`, no raw network access.

| Keyword | Purpose | Direction |
|---------|---------|-----------|
| `cn.req` | Incoming request data | Read |
| `cn.res` | Outgoing response control | Write |
| `cn.db` | Persistence | Read/Write |
| `cn.log` | Logging | Write |
| `cn.auth` | Session and permissions | Read/Write |
| `cn.mail` | Send e-mail | Write |
| `cn.crypto` | Hashing, tokens, HMAC | Read |
| `cn.io` | Outbound requests (key-authenticated) | Read |
| `cn.format` | Value formatting (currency, date, number) | Read |

#### `cn.req` — Request Data

| Field | Type | Description |
|-------|------|-------------|
| `cn.req.path` | string | URL path |
| `cn.req.method` | string | HTTP method |
| `cn.req.headers` | table | Request headers |
| `cn.req.query` | table | Query string parameters |
| `cn.req.body` | string | Raw body |

#### `cn.res` — Response Control

| Function | Description |
|----------|-------------|
| `cn.res.status(code)` | Set HTTP status |
| `cn.res.header(key, value)` | Set response header |
| `cn.res.body(content)` | Set response body |
| `cn.res.json(table)` | Send JSON response (sets Content-Type) |
| `cn.res.redirect(url)` | Redirect (302) |

#### `cn.db` — Persistence

| Function | Description | Limit |
|----------|-------------|-------|
| `cn.db.get(table, where)` | Query records | — |
| `cn.db.set(table, data)` | Insert record | max_db_writes |
| `cn.db.update(table, where, data)` | Update records | max_db_writes |
| `cn.db.delete(table, where)` | Delete records | max_db_writes |

#### `cn.auth` — Session and Permissions

| Field/Function | Description |
|----------------|-------------|
| `cn.auth.user` | Current user (id, email, role) |
| `cn.auth.role` | Role string |
| `cn.auth.login(credentials)` | Create session |
| `cn.auth.logout()` | Destroy session |

#### `cn.mail` — Send E-mail

| Function | Description | Limit |
|----------|-------------|-------|
| `cn.mail.send(to, subject, body)` | Send plain text e-mail | max_mail_per_min |

#### `cn.crypto` — Security

| Function | Description |
|----------|-------------|
| `cn.crypto.hash(value)` | Hash a value |
| `cn.crypto.token()` | Generate secure random token |
| `cn.crypto.verify(value, hash)` | Verify hash |

#### `cn.io` — Outbound Requests

Outbound requests require a pre-configured API key. Without a valid key
the request is never sent. Configuration in `server.toml`:

```toml
[io.stripe]
url = "https://api.stripe.com"
key = "sk_live_..."

[io.sendgrid]
url = "https://api.sendgrid.com"
key = "SG..."
```

| Function | Description |
|----------|-------------|
| `cn.io(service, path, data)` | Authenticated request to configured service |

```lua
local result = cn.io("stripe", "/v1/charges", {amount = 2000, currency = "eur"})
```

#### `cn.format` — Value Formatting

Available both as Lua function in extensions and as template filter.

| Function | Description |
|----------|-------------|
| `cn.format.currency(value, code)` | Format as currency |
| `cn.format.date(timestamp, locale)` | Format as localised date |
| `cn.format.number(value, locale)` | Format with locale grouping |

```lua
cn.format.currency(19.99, "EUR")     -- "19,99 €"
cn.format.date(1706100000, "de-DE")  -- "24. Januar 2026"
cn.format.number(1337.5, "en-GB")    -- "1,337.50"
```

Template filter equivalent:

```
{{ price | format "currency" "EUR" }}
{{ order.date | format "date" "de-DE" }}
{{ quantity | format "number" "en-GB" }}
```

#### `cn.log` — Logging

| Function | Description |
|----------|-------------|
| `cn.log.info(message)` | Informational |
| `cn.log.warn(message)` | Warning |
| `cn.log.error(message)` | Error |
| `cn.log.debug(message)` | Debug |

### Extension Types

A file exports one or more functions. The function name determines its role:

#### Route Extension — `function route()`

Runs before template rendering for a matching route.

```lua
-- extensions/checkout.lua
function route()
    local user = cn.auth.user
    if not user then
        return cn.res.redirect("/login")
    end
    local items = cn.db.get("cart", {user_id = user.id})
    if #items == 0 then
        return cn.res.redirect("/shop")
    end
end
```

#### API Extension — `function api(args)`

Provides data for `{! api !}` blocks. Receives explicitly passed
template variables as `args`.

```lua
-- extensions/stock_feed.lua
function api(args)
    local product = cn.db.get("products", {id = args.product_id})
    cn.res.json({
        stock = product.quantity,
        price = cn.format.currency(product.price, args.currency)
    })
end
```

#### Function Extension — `function fn(args)`

Exposes a callable function for CAST syntax.

```lua
-- extensions/discount.lua
function fn(args)
    local amount = args.amount
    if cn.auth.role == "vip" then
        return amount * 0.8
    end
    return amount
end
```

### Parameter Passing

Template variables are passed explicitly to extensions. Only arguments
in the call are visible to the extension — nothing else.

```html
{{ product_id = "abc-123" }}
{{ currency = "EUR" }}
{! api cnx:stock_feed[product_id, currency] !}
{! bind cnx:stock_feed !}
    <p>{{ stock }} in stock — {{ price }}</p>
{! /bind !}
```

The extension receives positional arguments: `args["1"]` = product_id value,
`args["2"]` = currency value. All other template variables are invisible to it.

> **Concept:** Explicit parameter passing is a security boundary. An extension
> cannot sniff session data, user input, or unrelated variables unless
> the template author deliberately passes them. The template is the
> contract between markup and logic.

### Route Binding

Route extensions are bound by convention or configuration:

**Convention:** Filename matches route segment.
`checkout.lua` → runs on `/checkout`

**Configuration** (for non-matching names):

```toml
[extensions.routes]
"/checkout" = "checkout"
"/contact/send" = "contact_form"
```

### Combined Extensions

A single file may export multiple extension types:

```lua
-- extensions/pricing.lua

function fn(args)
    return cn.format.currency(args.amount * 1.19, "EUR")
end

function api(args)
    local products = cn.db.get("products", {featured = true})
    local result = {}
    for _, p in ipairs(products) do
        result[#result + 1] = {
            name = p.name,
            price = cn.format.currency(p.price * 1.19, "EUR")
        }
    end
    cn.res.json({products = result})
end
```

### Example Extension: Currency Conversion

Demonstrates the subfolder structure with `require()` for modular code.

**File structure:**
```
extensions/
└── currency_convert/
    ├── init.lua        ← Entry point
    └── rates.lua       ← Exchange rates module
```

**init.lua:**
```lua
-- extensions/currency_convert/init.lua
local rates = require("rates")

function fn(args)
    local amount = tonumber(args["1"]) or 0
    local from = args["2"] or "EUR"
    local to = args["3"] or "EUR"
    
    local result = rates.convert(amount, from, to)
    if result == nil then
        cn.log.warn("Unknown currency pair: " .. from .. " -> " .. to)
        return "N/A"
    end
    
    return cn.format.currency(result, to)
end

function api(args)
    local amount = tonumber(args["1"]) or 0
    local from = args["2"] or "EUR"
    local to = args["3"] or "USD"
    local result = rates.convert(amount, from, to)
    
    cn.res.json({
        original = amount,
        converted = result,
        from = from,
        to = to,
        formatted = cn.format.currency(result, to)
    })
end
```

**rates.lua:**
```lua
-- extensions/currency_convert/rates.lua
local M = {}

M.data = {
    EUR = 1.0,
    USD = 1.08,
    GBP = 0.86,
    CHF = 0.93,
    JPY = 164.50,
}

function M.get(currency)
    return M.data[currency]
end

function M.convert(amount, from, to)
    local from_rate = M.get(from)
    local to_rate = M.get(to)
    if not from_rate or not to_rate then
        return nil
    end
    return amount / from_rate * to_rate
end

return M
```

**Template usage:**

```html
{{ price_eur = 99.90 }}
<p>In USD: {( cnx:currency_convert[price_eur, "EUR", "USD"] )}</p>
<p>In GBP: {( cnx:currency_convert[price_eur, "EUR", "GBP"] )}</p>

{! api cnx:currency_convert[amount, from_currency, to_currency] | websocket !}
    <p>{{ formatted }}</p>
{! endapi !}
```

> **Concept:** Nine keywords cover everything from blog to shop: receive
> requests, respond, persist, authenticate, notify, secure, connect to
> third parties, format values, and log. The sandbox knows only `cn.*` —
> everything else is blocked by design. No filesystem, no system calls,
> no uncontrolled network access. Extensions handle business logic, not
> infrastructure.

---

## Modifiers

### Complete Modifier Reference

| Modifier | Applies to | Value | Effect |
|----------|-----------|-------|--------|
| `upper` | `{{ }}` | — | Uppercase |
| `lower` | `{{ }}` | — | Lowercase |
| `trim` | `{{ }}` | — | Strip whitespace |
| `length` | `{{ }}` | — | Count characters or items |
| `truncate` | `{{ }}` | Number | Cut at N characters |
| `slug` | `{{ }}` | — | URL-safe slug |
| `escape` | `{{ }}` | — | HTML entity encoding |
| `raw` | `{{ }}` | — | Skip HTML escaping |
| `default` | `{{ }}` | String | Fallback value |
| `translate` | `{{ }}` | — | i18n CSV lookup |
| `format` | `{{ }}` | Type + locale/code | Format value (currency, date, number) |
| `date` | `{{ }}` | — | Date formatting |
| `unix` | `{{ }}` | — | Unix timestamp |
| `transform` | `{{ }}` | Name | Asset URL transform |
| `secure` | `{{ }}` | — | Signed asset URL |
| `websocket` | `{! api !}` | — | WebSocket transport |
| `sse` | `{! api !}` | — | SSE transport |
| `fetch` | `{! api !}` | — | Single fetch |
| `poll` | `{! api !}` | Milliseconds | Repeat interval |
| `debug` | `{! api !}` | — | Console logging |
| `action` | `{( )}` | URL | Server action endpoint |
| `data` | `{( )}` | Variable | Action payload |
| `loading` | `{( )}` | Text | Loading state label |
| `loading-class` | `{( )}` | Class | Loading state CSS class |
| `open` | `{( )}` | Name | Open modal |
| `close` | `{( )}` | — | Close modal |
| `slotlist` | `{! extends !}` | — | Slot-only inheritance mode |
| `slotlist` | `{( )}` | — | Enable slot overrides on preset |
| `toc` | `{( docs )}` | — | Include table of contents |
| `format` | `{( docs )}` | `md\|troff\|adoc\|rst` | Override format detection |
| `where` | `{* *}` | Condition | Filter rows |
| `order` | `{* *}` | Field+direction | Sort |
| `limit` | `{* *}` | Number | Row limit |
| `offset` | `{* *}` | Number | Row offset |
| `path` | `{* volume *}` | Directory | Storage path |
| `accept` | `{* volume *}` | Extensions | Allowed types |
| `transforms` | `{* volume *}` | Definitions | Image sizes |
| `secure` | `{* volume *}` | — | Token protection |
| `role` | `{* auth *}` | String | User role on register |

---

## Constants

> **Concept:** Constants provide framework-aware values without hardcoding
> paths or versions. They follow the `cn:type.name` pattern and are resolved
> at render time. This means asset paths work regardless of where the project
> is deployed.

System constants follow the `cn:type.name` pattern inside `{{ }}`.

| Constant | Value |
|----------|-------|
| `cn:path.styles` | `/assets/styles/` |
| `cn:path.scripts` | `/assets/scripts/` |
| `cn:path.images` | `/assets/images/` |
| `cn:list.workspaces` | Array of bundle names |
| `cn:list.themes` | Array of available themes |
| `cn:meta.version` | Framework version string |
| `cn:meta.port` | Server port number |

```html
<link rel="stylesheet" href="{{ cn:path.styles }}castd.css">
<script src="{{ cn:path.scripts }}castd.js"></script>
```

---

## Naming Conventions

> **Concept:** Naming conventions eliminate ambiguity. A file named after its
> folder can always be found without guessing. Dots in preset names map to
> slashes, so the namespace is the filesystem. URL paths map directly to
> template folders. No routing table, no configuration — structure is convention.

### File Naming

Every file is named after its containing folder:

```
button/button.html       correct
button/index.html        WRONG
button/template.html     WRONG
```

This applies to templates, presets, and all associated files (`.html`, `.css`,
`.js`, `.csv`).

### Preset Naming

Dots in preset names map to directory separators:

```
cn:preset.form.button    → presets/components/form/button/button.html
cn:preset.ui.card        → presets/components/ui/card/card.html
cn:preset.layout.header  → presets/components/layout/header/header.html
```

### Template Routing

URL paths map to template folders:

```
/                        → templates/{home}/{home}.html
/docs                    → templates/docs/docs.html
/docs/forms              → templates/docs/forms/forms.html
/docs/forms/button       → templates/docs/forms/button/button.html
```

The home route is configurable via `bundle.toml`.

### i18n CSV Files

Translation files use semicolon separation: `key;value;lang`

```
title;Welcome;en-GB
title;Willkommen;de-DE
```

Placed alongside their template or preset as `{folder}/{folder}.csv`.

---

## Configuration

> **Concept:** Configuration has two levels: server (how the process runs) and
> bundle (how content behaves). CLI flags override server.toml, so the same
> binary works for development and production without rebuilding. Bundles are
> self-contained — everything a bundle needs to run is in its folder.

### server.toml

Placed at project root. Configures the server process.

```toml
[server]
port = 1337                      # HTTP port (ignored with socket)
bundle = "my-bundle"             # Default bundle from workspace/
# socket = "/var/run/cn.sock"    # Unix socket for reverse proxy
```

### bundle.toml

Placed at `workspace/{bundle}/bundle.toml`. Configures the bundle.

```toml
[routing]
home = "home"                    # Folder served at / (default: "home")
```

### CLI Flags

CLI flags override `server.toml` values:

```bash
./castd.sh start --bundle my-bundle --port 8080
./castd.sh start --bundle my-bundle --socket /var/run/cn.sock
```

---

## Quick Reference Card

```
DATA        {{ variable }}              Output
            {{ variable | modifier }}   Transform
            {{ name = "value" }}        Assign
            {{ cn:type.name }}          System constant

LOGIC       {! if x == y !}...{! endif !}
            {! each items !}...{! endeach !}
            {! api extension_name | transport !}...{! endapi !}
            {! bind var1, var2 !}...{! endbind !}
            {! extends "path" | slotlist !}

PRESETS     {( cn:preset.category.name["arg"] | mod )}
            {( cn:preset.name | slotlist )}...{( endpreset )}
            {( slot name )}...{( endslot )}
            {( cn:snippet.name )}...{( endsnippet )}
            {( cn:snippet.name[param="val"] )}

PERSIST     {* read db.table | where x=y *}...{* endread *}
            {* write db.table *}...{* endwrite *}
            {* update db.table | where x=y *}...{* endupdate *}
            {* delete db.table | where x=y *}
            {* auth login *}...{* endauth *}
            {* require role="admin" *}...{* endrequire *}
            {* volume "name" | path="...", accept="..." *}

COMMENTS    {# Stripped from output. #}

DOCS        {( cn:preset.docs["/file.md"] )}         Import documentation
            {( cn:preset.docs["/man.1"] | toc )}    With table of contents

EXTENSIONS  function route()                Before rendering
            function api(args)              Data for API/bind
            function fn(args)               Template function
            {( cnx:name[arg1, arg2] )}     Call function extension
```

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
