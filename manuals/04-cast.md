# CAST — Content & Structure Templating

**Version:** 1.0  
**Status:** Active

---

## Overview

CAST (Content & Structure Templating) is castd's template language. It provides five distinct syntax types, each visually distinguishable for a specific purpose.

---

## The Five Syntaxes

| Syntax | Purpose | Visual Cue |
|--------|---------|------------|
| `{{ }}` | Data | Double braces = data output/assignment |
| `{! !}` | Logic | Exclamation = control flow |
| `{( )}` | Presets | Parenthesis = component/macro inclusion |
| `{* *}` | Persistence | Asterisk = storage operations |
| `{# #}` | Comments | Hash = developer notes |

---

## Data: `{{ }}`

Output variables and assign values.

### Variable Output

```html
{{ name }}                          — Escaped output
{{ name | raw }}                    — Unescaped (HTML)
{{ product.price }}                 — Property access
{{ items[0] }}                      — Array index
{{ items[index] }}                  — Dynamic index
```

### Modifiers

| Modifier | Description |
|----------|-------------|
| `raw` | Unescaped output |
| `upper` | Uppercase |
| `lower` | Lowercase |
| `date` | Format as date |
| `slug` | URL-safe string |
| `truncate=N` | Limit to N characters |
| `markdown` | Convert Markdown to HTML |
| `currency` | Format as currency |
| `translate` | Lookup in translations |
| `length` | Array/string length |

**Chaining:**
```html
{{ title | lower | truncate=50 }}
```

### Assignment

```html
{{ name = "Guava" }}                — String
{{ count = 42 }}                    — Number
{{ active = true }}                 — Boolean
{{ copy = original }}               — Variable copy
{{ data = "/path.json" | import }}  — Load JSON/CSV
```

### Auto-Object Creation

```html
{{ item.name = "Guava" }}           — Creates item if missing
{{ item.price = 1.49 }}             — Adds property
{{ cart[0] = item }}                — Creates array if missing
```

### Debug

```html
{{ dump variable }}                 — Output variable structure
```

---

## Logic: `{! !}`

Control flow and reactivity.

### Conditionals

```html
{! if condition !}
  <!-- content -->
{! endif !}

{! if x == y !}
  <!-- when equal -->
{! endif !}
```

**Else and elseif:**

```html
{! if role == "admin" !}
  Full access.
{! elseif role == "editor" !}
  Edit access.
{! else !}
  Read-only.
{! endif !}
```

### Iteration

```html
{! each items !}
  <div>{{ item.name }}</div>
  <span>Index: {{ index }}</span>
{! endeach !}
```

Built-in variables inside `each`:
- `{{ item }}` — Current element (always implicit)
- `{{ index }}` — Current index (0, 1, 2...)

### Binding (Reactivity)

Bind blocks enable reactive updates while respecting the LEAT pattern. When a bound variable changes, only the affected fragment re-renders — the server sends a targeted HTML update, not a full page.

```html
{! bind cart.total !}
  <strong>{{ cart.total | currency }}</strong>
{! endbind !}

{! bind a, b !}
  <!-- Re-renders when a OR b changes -->
{! endbind !}
```

### API Connections

API connections extend LEAT to real-time scenarios. Each message follows the same linear flow: Event (message arrives) → Actor (handler processes) → Turnback (response sent).

```html
{! api "/endpoint" | websocket !}
  <!-- Real-time bidirectional -->
{! endapi !}

{! api "/endpoint" | sse !}
  <!-- Server-sent events -->
{! endapi !}

{! api "/endpoint" | fetch & poll=5000 !}
  <!-- Polling every 5 seconds -->
{! endapi !}
```

### Modals

```html
{! modal "confirm" !}
  <h2>Are you sure?</h2>
  {( cn:preset.form.button["Yes"] | action="delete", close )}
  {( cn:preset.form.button["Cancel"] | close )}
{! endmodal !}
```

### Tabs

```html
{! tabs !}
  {! tab "details" | active !}Details{! endtab !}
  {! tab "specs" !}Specifications{! endtab !}
  
  {! panel "details" !}
    <p>Product details...</p>
  {! endpanel !}
  
  {! panel "specs" !}
    <p>Technical specifications...</p>
  {! endpanel !}
{! endtabs !}
```

### Slots (Template Inheritance)

Slots define replaceable regions within templates and presets. A slot has a
name and default content. Child templates or preset consumers can override
individual slots without replacing the entire file.

**Definition:**
```html
{( slot title )}
    Default Title
{( endslot )}
```

**Template inheritance — slotlist mode:**

A base template defines the page skeleton with named slots:

```html
{# _base.html #}
<!doctype html>
<html lang="en-GB">
<head>
    <title>{( slot title )}Default{( endslot )}</title>
</head>
<body>
    {( slot header )}
        {( cn:preset.layout.header )}
    {( endslot )}

    <main>
        {( slot content )}{( endslot )}
    </main>

    {( slot footer )}
        {( cn:preset.layout.footer )}
    {( endslot )}
</body>
</html>
```

A child template extends the base and overrides only the slots it needs:

```html
{! extends "_base.html" | slotlist !}

{( slot title )}Home — CASTD{( endslot )}

{( slot content )}
<h1>Welcome</h1>
<p>This replaces the empty content slot.</p>
{( endslot )}
```

The `header` and `footer` slots are not overridden, so they keep their
default content from the base template.

**Template inheritance — full mode (default):**

Without the `slotlist` modifier, the child template completely replaces the
base. Slots from the base are ignored.

```html
{! extends "_base.html" !}

<!doctype html>
<html>
  <!-- Entirely custom page, base template slots ignored -->
</html>
```

**Inheritance chains:**

Templates can extend templates that extend other templates. The server
resolves the chain recursively.

```html
{# _base.html defines the skeleton #}
{# _docs.html extends _base.html, adds a sidebar slot #}
{# forms.html extends _docs.html, fills the content slot #}
```

**Rules:**
- `{! extends !}` must be the first meaningful token in the file
  (leading whitespace and comments are allowed before it).
- In **slotlist** mode: only `{( slot )}` blocks are permitted; no loose
  HTML between them.
- In **full** mode: the child replaces the entire base; slots are ignored.
- Slots not overridden by the child keep their default content from the base.
- An empty slot override (`{( slot x )}{( endslot )}`) produces no output
  — this is intentional (override with nothing).
- Nested slots within a single template are supported.
- A slot defined in the child but absent in the base is silently ignored.

**Path resolution:**

```
{! extends "_base.html" !}        Relative to templates/ root
{! extends "../_base.html" !}     Relative to current template directory
```

### Attributes

Use within HTML attributes:

```html
<a {! link "/about" !}>About</a>
<form {! action="submit" !}>
<input {! validate="blur" !}>
<input {! validate="input" & debounce=300 !}>
```

---

## Presets: `{( )}`

Include components and define inline macros.

### Component Inclusion

```html
{( cn:preset.form.button["Submit"] )}
{( cn:preset.layout.header[current="docs"] )}
{( cn:preset.ui.card[item.name, item.price] )}
```

### With Modifiers

```html
{( cn:preset.form.button["Submit"] | action="/save" )}
{( cn:preset.form.button["Delete"] | open="confirm" )}
{( cn:preset.form.button["Cancel"] | close )}
```

| Modifier | Description |
|----------|-------------|
| `action="/path"` | Trigger server action |
| `data=var` | Send data with action |
| `loading="Text"` | Loading state text |
| `loading-class="x"` | CSS class during loading |
| `open="modal"` | Open modal dialogue |
| `close` | Close current modal |

### Built-in Presets

```html
{( cn:preset.date )}                    — Current date
{( cn:preset.date | YYYY-MM-DD )}       — Formatted date
{( cn:preset.hash | 8 )}                — Random hash
{( cn:preset.uuid )}                    — UUID v4
{( cn:preset.slug["Hello World"] )}     — URL slug
{( cn:preset.random[1, 100] )}          — Random number
{( cn:preset.docs["/readme.md"] )}      — Import and render documentation
{( cn:preset.docs["/man/tar.1"] | toc )}  — With table of contents
```

### Inline Macros

Inline macros are locally defined, reusable templates within the same file.

**Definition with parameters:**
```html
{( preset product-row[name, price] )}
  <tr>
    <td>{{ name }}</td>
    <td>{{ price | currency }}</td>
  </tr>
{( endpreset )}
```

**Invocation:**
```html
{( product-row["Guava", 1.49] )}
{( product-row["Apple", 2.99] )}
```

**Definition without parameters:**
```html
{( preset card )}
  <div class="card">
    <h3>{{ title }}</h3>
    <p>{{ content }}</p>
  </div>
{( endpreset )}

{( card[title="Hello", content="World"] )}
```

Inline macros are scoped to the current template file. They cannot be
referenced from other templates — use presets for shared components.

---

## Persistence: `{* *}`

Database and authentication operations.

### CRUD Operations

**Create:**
```html
{* write db.posts *}
  {{ title = form.title }}
  {{ content = form.content }}
  {{ author = user.id }}
  {{ created = now }}
{* endwrite *}
```

**Read (list):**
```html
{* read db.posts | where published=true, order=created desc, limit=10 *}
  {! each items !}
    <article>
      <h2>{{ item.title }}</h2>
    </article>
  {! endeach !}
{* endread *}
```

**Read (single):**
```html
{* read db.posts | where slug=route.slug *}
  <article>{{ item.content | raw }}</article>
{* endread *}
```

**Update:**
```html
{* update db.posts | where id=route.id *}
  {{ title = form.title }}
  {{ updated = now }}
{* endupdate *}
```

**Delete:**
```html
{* delete db.posts | where id=route.id *}
```

### Query Modifiers

| Modifier | Example |
|----------|---------|
| `where` | `where id=5` |
| `where` | `where active=true, role="admin"` (AND) |
| `order` | `order=created desc` |
| `limit` | `limit=10` |
| `offset` | `offset=20` |

### Authentication

```html
{* auth login *}
  {! if success !}
    {{ redirect = "/dashboard" }}
  {! endif !}
  {! if error !}
    <p class="error">{{ error }}</p>
  {! endif !}
{* endauth *}

{* auth logout *}

{* auth register | role="user" *}
  ...
{* endauth *}
```

### Permission Checks

```html
{* require role="admin" *}
  <a href="/admin">Admin Panel</a>
{* endrequire *}

{* require permission="posts.write" *}
  <button>New Post</button>
{* endrequire *}

{* require logged-in *}
  <p>Welcome {{ user.name }}</p>
{* endrequire *}
```

### Built-in Variables

| Variable | Description |
|----------|-------------|
| `{{ user }}` | Current user (or null) |
| `{{ user.id }}` | User ID |
| `{{ user.email }}` | User email |
| `{{ user.role }}` | User role |
| `{{ form.* }}` | Form data (POST) |
| `{{ route.* }}` | URL parameters |
| `{{ now }}` | Current timestamp |
| `{{ redirect }}` | Set redirect |

### Volumes (Digital Asset Management)

**Define:**
```html
{* volume "images" | path="/media/images", accept="jpg,png,webp", transforms="thumb:200x200" *}
{* volume "docs" | path="/media/docs", accept="pdf", secure *}
```

**Upload:**
```html
{* write volume.images *}
  {( cn:preset.form.file | accept="image/*" )}
{* endwrite *}
```

**List:**
```html
{* read volume.images | order=created desc *}
  {! each items !}
    <img src="{{ item.url | transform=thumb }}" alt="{{ item.alt }}">
  {! endeach !}
{* endread *}
```

---

## Comments: `{# #}`

```html
{# Single line comment #}

{# 
   Multi-line
   comment 
#}

{{ name = "value" }}  {# Inline note #}
```

Comments are stripped from output.

---

## System Constants

### Paths (cn:path.*)

All paths end with `/` for easy concatenation.

```html
{{ cn:path.styles }}    → /assets/styles/
{{ cn:path.scripts }}   → /assets/scripts/
{{ cn:path.images }}    → /assets/images/
```

**Usage:**
```html
<link rel="stylesheet" href="{{ cn:path.styles }}castd.css">
```

### Lists (cn:list.*)

```html
{! each cn:list.workspaces !}
  <li>{{ item }}</li>
{! endeach !}

{! each cn:list.themes !}
  <option>{{ item }}</option>
{! endeach !}
```

### Meta (cn:meta.*)

```html
{{ cn:meta.version }}   → CASTD version
{{ cn:meta.port }}      → Server port (default: 1337)
```

---

## Naming Conventions

- **kebab-case** for all names: `product-card`, `hero-section`
- **Dot notation** for namespace/property access: `cn.form.button`, `item.price`

```html
{( cn:preset.product-card )}    ✓
{( cn:preset.productCard )}     ✗
```

---

## i18n (Internationalisation)

### Translation Files

CSV format with semicolon separator:

```csv
key;value;lang
button.submit;Submit;en-GB
button.submit;Absenden;de-DE
```

### Usage

```html
<button>{{ "button.submit" | translate }}</button>
```

### Language Resolution

1. Cookie (`castd_prefs.lang`)
2. `Accept-Language` header
3. Default (`en-GB`)

---

## CSS/JS Aggregation

The server automatically:

1. Scans templates for preset usage
2. Collects CSS/JS from used presets only
3. Deduplicates (each file once)
4. Inserts CSS in `<head>`, JS at end of `<body>`

### CSS Layer Hierarchy

```css
@layer general,
       castd.base,
       castd.presets,
       theme;
```

Later layers override earlier ones. No `!important` needed.

---

## Extensions: `{( cnx:* )}`

Extensions are Lua scripts that provide custom business logic. They use the **Call syntax** `{( )}`, consistent with presets.

### Syntax

```html
{( cnx:extension_name[arg1, arg2, arg3] )}
```

Arguments can be:
- **Literals:** `"EUR"`, `42`, `true`
- **Variables:** `price_eur`, `user.currency`

### Example

```html
{{ price_eur = 100 }}
<p>Price in USD: {( cnx:currency_convert[price_eur, "EUR", "USD"] )}</p>
<p>Price in GBP: {( cnx:currency_convert[50, "EUR", "GBP"] )}</p>
```

### Syntax Comparison

| Type | Syntax | Example |
|------|--------|---------|
| Preset | `{( cn:preset.* )}` | `{( cn:preset.form.button["Submit"] )}` |
| Extension | `{( cnx:* )}` | `{( cnx:currency_convert[100, "EUR", "USD"] )}` |

Both use `{( )}` because both are **calls** that produce output.

### Available Extensions

Extensions are loaded from `castd/backend/extensions/`. Each `.lua` file exports a `fn(args)` function that receives positional arguments as string keys (`args["1"]`, `args["2"]`, etc.).

### Creating Extensions

```lua
-- myextension.lua
function fn(args)
    local first = args["1"]   -- First argument
    local second = args["2"]  -- Second argument
    return "Result: " .. first .. ", " .. second
end
```

See [05-cast-reference.md](05-cast-reference.md) for the full helper and extension reference.

---

## See Also

- **Syntax reference:** See [05-cast-reference.md](05-cast-reference.md)
- **Formal grammar:** See [06-cast-grammar.md](06-cast-grammar.md)
- **Preset system:** See [10-presets.md](10-presets.md)
- **Context system:** See [12-context.md](12-context.md)

---

*Copyright 2025 Vivian Voss. Apache-2.0*
