# Preset System

**Version:** 1.0  
**Status:** Active

---

## Overview

Presets are server-rendered components that generate HTML, with CSS and JavaScript automatically aggregated. They follow the single-responsibility principle: one preset = one job.

---

## Preset Categories

### Components

Visual building blocks for user interfaces.

| Namespace | Purpose | Example |
|-----------|---------|---------|
| `cn:preset.form.*` | Form elements | `button`, `input`, `select` |
| `cn:preset.ui.*` | UI components | `modal`, `tabs`, `toast` |
| `cn:preset.layout.*` | Layout parts | `header`, `footer`, `nav` |

```html
{( cn:preset.form.button["Submit"] )}
{( cn:preset.form.input | type="email", placeholder="you@example.com" )}
{( cn:preset.ui.modal )}
{( cn:preset.layout.header )}
```

### Extensions

Functional utilities for the server.

| Extension | Purpose | Example |
|-----------|---------|---------|
| `cn:preset.hash` | Random hash | `{( cn:preset.hash \| 8 )}` → `a3f8b2c1` |
| `cn:preset.uuid` | UUID v4 | `{( cn:preset.uuid )}` |
| `cn:preset.date` | Date formatting | `{( cn:preset.date \| YYYY-MM-DD )}` |
| `cn:preset.slug` | URL slug | `{( cn:preset.slug["Hello World"] )}` → `hello-world` |
| `cn:preset.random` | Random number | `{( cn:preset.random[1, 100] )}` |

### Themes

Visual customisations applied framework-wide.

```
presets/themes/
└── metroline/       (Default theme, auto-injected)
    ├── metroline.css
    └── metroline.js
```

---

## Syntax

### Basic Call

```html
{( cn:preset.form.button["Submit"] )}
```

### With Parameters

```html
{( cn:preset.form.input[
    type="email",
    name="email",
    placeholder="you@example.com",
    required
] )}
```

### With Modifiers

```html
{( cn:preset.form.button["Save"] | action="/api/save" )}
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

---

## Name-to-Path Mapping

Preset names map directly to directory paths. Dots become directory separators.

| Call | Path |
|------|------|
| `{( cn:preset.form.button )}` | `components/form/button/` |
| `{( cn:preset.ui.card )}` | `components/ui/card/` |
| `{( cn:preset.header )}` | `components/header/` |
| `{( cn:preset.hash )}` | `extensions/hash/` |

---

## Preset File Structure

Each preset contains:

```
form/button/
├── button.html     (Required — template)
├── button.css      (Styles)
├── button.js       (Interactivity, optional)
└── button.csv      (Translations)
```

### HTML Template

```html
{# button.html #}
<button type="{{ type | default='button' }}" class="{{ variant }}">
    {{ label }}
</button>
```

### CSS

Preset CSS uses `@layer castd`:

```css
@layer castd {
    button {
        /* Minimal styles — framework handles base styling */
    }
}
```

### JavaScript (optional)

Client-side interactivity after server rendering:

```javascript
// button.js
document.querySelectorAll("button[progress]").forEach(btn => {
    // Hold-to-confirm logic
});
```

---

## Lookup Cascade

When you call a preset, the server looks in two places:

1. **Bundle first:** `workspace/{bundle}/presets/components/{path}/`
2. **Framework fallback:** `castd/frontend/presets/components/{path}/`

This allows bundles to override framework presets without modification.

---

## Preset Slots

Presets can define named slots — replaceable regions with default content.
When calling a preset, consumers override individual slots without replacing
the entire preset template.

### Defining Slots in a Preset

Use `{( slot name )}...{( endslot )}` inside the preset HTML:

```html
{# layout/header/header.html #}
<header>
    {( slot logo )}
        <img src="/assets/images/castd-logo.svg" alt="CASTD">
    {( endslot )}

    <nav>
        {( slot nav )}
            <a href="/">Home</a>
            <a href="/docs/">Docs</a>
        {( endslot )}
    </nav>
</header>
```

### Calling a Preset with Slot Overrides

Add `| slotlist` to the preset call and wrap the overrides between
the call and `{( endpreset )}`:

```html
{( cn:preset.layout.header | slotlist )}
    {( slot logo )}
        <img src="/assets/images/my-brand.svg" alt="My Brand">
    {( endslot )}
{( endpreset )}
```

The `nav` slot is not overridden, so it keeps its default content from the
preset. Only the `logo` slot is replaced.

### Calling a Preset Without Slot Overrides

A normal preset call (without `| slotlist`) renders the preset with all
default slot content — exactly as before slots existed:

```html
{( cn:preset.layout.header )}
```

### Rules

- Slot overrides require the `| slotlist` modifier on the preset call.
- The override block ends with `{( endpreset )}`.
- Inside the override block, only `{( slot )}` blocks are meaningful;
  content outside slots is ignored.
- Slots not overridden keep their default content from the preset.
- An empty slot override (`{( slot x )}{( endslot )}`) produces no output.
- Slot names must match exactly between preset definition and override.
- A slot override for a name not present in the preset is silently ignored.

### Difference from Snippets and Inline Presets

| Feature | Slot Override | Snippet | Inline Preset |
|---------|---------------|---------|---------------|
| Purpose | Partial customisation of existing preset | Reusable fragment within one file | Reusable fragment within one file |
| Scope | Cross-file (preset → consumer) | Single file | Single file |
| Mechanism | Named replacement regions | Named inline definition | Named inline definition |
| Syntax | `{( preset \| slotlist )}...{( endpreset )}` | `{( cn:snippet.name )}` | `{( preset name[params] )}` |

---

## Inline Preset Definition

Define presets directly in templates:

```html
{( preset product-card[name, price, image] )}
    <article class="product">
        <img src="{{ image }}" alt="{{ name }}">
        <h3>{{ name }}</h3>
        <span class="price">{{ price | currency }}</span>
    </article>
{( endpreset )}

{# Usage #}
{( product-card["Guava", "1.49", "/img/guava.jpg"] )}
{( product-card["Apple", "2.99", "/img/apple.jpg"] )}
```

---

## Snippets

Snippets are locally defined templates within the same file. They have no file representation.

### Definition (no parameters)

```html
{( cn:snippet.codeblock )}
<div class="example">
    <pre><code>{{ code }}</code></pre>
</div>
{( endsnippet )}
```

### Invocation (with parameters)

```html
{( cn:snippet.codeblock[code="<button>Click</button>"] )}
```

### Difference from Presets

| Feature | Preset | Snippet |
|---------|--------|---------|
| Storage | External files | Inline in template |
| Reuse | Across projects | Within single file |
| Syntax (def) | Create file | `{( cn:snippet.name )}...{( endsnippet )}` |
| Syntax (call) | `{( cn:preset.name )}` | `{( cn:snippet.name[params] )}` |

### Snippets as Preset Parameters

Pass multi-line content to presets:

```html
{( cn:snippet.preview )}
<button>Click me</button>
{( endsnippet )}

{( cn:snippet.code )}
<button>Click me</button>
{( endsnippet )}

{( cn:preset.docs.example[preview="cn:snippet.preview", code="cn:snippet.code"] )}
```

---

## CSS/JS Aggregation

The server automatically:

1. Scans templates for preset usage
2. Collects CSS/JS from used presets only
3. Deduplicates (each file once)
4. Inserts CSS in `<head>`, JS at end of `<body>`

### CSS Layer Hierarchy

```css
@layer globals,
       castd.base,
       castd.presets,
       theme;
```

| Layer | Content |
|-------|---------|
| `globals` | Reset, basics |
| `castd.base` | Framework CSS |
| `castd.presets` | Preset CSS |
| `theme` | Theme CSS |

---

## i18n (Translations)

### CSV Format

Each preset carries translations in a CSV file:

```csv
key;value;lang
button.label;Submit;en-GB
button.label;Absenden;de-DE
button.label;Verzenden;nl-NL
```

### Usage in Templates

```html
<button>{{ "button.label" | translate }}</button>
```

### Language Resolution

1. Cookie (`castd_prefs.lang`)
2. `Accept-Language` header
3. Default (`en-GB`)

---

## Naming Conventions

- **kebab-case** for all names: `product-card`, `hero-section`
- **cn:** prefix for official CASTD presets
- **No prefix** for third-party: `stripe-checkout`, `paypal-express`

```html
{( cn:preset.ui.product-card )}     ✓
{( stripe-checkout )}               ✓
{( cn:preset.ui.productCard )}      ✗
```

---

## Built-in Extensions Reference

### Date

```html
{( cn:preset.date )}                — Current date (default format)
{( cn:preset.date | unix )}         — Unix timestamp
{( cn:preset.date | YYYY-MM-DD )}   — 2026-01-25
{( cn:preset.date | DD.MM.YYYY )}   — 25.01.2026
```

### Hash

```html
{( cn:preset.hash )}                — Default length
{( cn:preset.hash | 5 )}            — a3f8b
{( cn:preset.hash | 32 )}           — Long hash
```

### UUID

```html
{( cn:preset.uuid )}                — v4 UUID
```

### Slug

```html
{( cn:preset.slug["Hello World!"] )}  — hello-world
```

### Random

```html
{( cn:preset.random[1, 100] )}      — Random number 1-100
```

### Docs (Documentation Translator)

Import and render documentation files from various formats. The server parses
the source file and outputs semantic HTML wrapped in `<article class="as-docs">`.

```html
{( cn:preset.docs["/manuals/readme.md"] )}
{( cn:preset.docs["/man/tar.1"] )}
```

**Supported formats:**

| Format | Extensions | Status |
|--------|-----------|--------|
| Markdown | `.md`, `.markdown` | Implemented |
| troff/mdoc (Unix Man Pages) | `.1` - `.8` | Implemented |
| AsciiDoc | `.adoc`, `.asciidoc` | Placeholder |
| reStructuredText | `.rst` | Placeholder |

Format is detected automatically from the file extension.

**Modifiers:**

| Modifier | Value | Effect |
|----------|-------|--------|
| `toc` | — | Include table of contents navigation |
| `format` | `md`, `troff`, `adoc`, `rst` | Override auto-detected format |

```html
{( cn:preset.docs["/readme.md"] | toc )}
{( cn:preset.docs["/content/guide"] | format="md" & toc )}
```

**Output structure:**

```html
<article class="as-docs">
    <header>
        <h1>Document Title</h1>
        <p class="docs-description">Description (from metadata)</p>
    </header>
    <nav class="docs-toc">
        <h2>Contents</h2>
        <ul>
            <li><a href="#section-id">Section</a></li>
        </ul>
    </nav>
    <div class="docs-content">
        <!-- Rendered HTML content -->
    </div>
</article>
```

The TOC navigation is only included when the `toc` modifier is present.

**Markdown features:**
- Headings (`#` - `######`)
- Bold (`**text**`), italic (`*text*`), inline code (`` `code` ``)
- Code blocks (triple backticks)
- Links (`[text](url)`)
- Unordered lists (`-`), ordered lists (`1.`)
- Blockquotes (`>`)
- Horizontal rules (`---`)
- Paragraphs (separated by blank lines)

**troff/mdoc features:**
- Title (`.Dt`, `.TH`)
- Sections (`.Sh`, `.SH`)
- Name and description (`.Nm`, `.Nd`)
- Cross-references (`.Xr` → rendered as links)
- Flags (`.Fl`), arguments (`.Ar`), optionals (`.Op`)
- Lists (`.Bl`, `.It`, `.El`)
- Bold (`.B`, `.Sy`), italic (`.I`, `.Em`)
- Date (`.Dd`), OS (`.Os`)
- Metadata (section number, description, see-also references)

---

## See Also

- **CAST syntax:** See [04-cast.md](04-cast.md)
- **Theme system:** See [09-theming.md](09-theming.md)

---

*Copyright 2025 Vivian Voss. Apache-2.0*
