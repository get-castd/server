# Styling

castd.css -- the standalone CSS framework. Works without JavaScript, without a
build step, and without the CASTD server.

---

## Architecture

The framework uses CSS cascade layers for predictable specificity:

```css
@layer globals, castd, theme;
```

| Layer | Purpose | Contents |
|-------|---------|----------|
| `globals` | Universal foundation | Box-sizing, body defaults, grid systems |
| `castd` | Component styling | Typography, forms, UI components |
| `theme` | Customisation | Colour and spacing tokens |

Layers are processed in declaration order. A selector in `theme` overrides
an identical selector in `castd`, regardless of specificity.

---

## Registered Properties

```css
@property --span-x {
    syntax: "<integer>";
    inherits: false;
    initial-value: 1;
}

@property --span-y {
    syntax: "<integer>";
    inherits: false;
    initial-value: 1;
}

@property --progress {
    syntax: "<angle>";
    initial-value: 0deg;
    inherits: false;
}
```

These properties are registered for animation capability and type safety.
Setting `inherits: false` prevents unintended inheritance in nested layouts.

---

## Grid Systems

Two grid systems are available. Use them independently or nest them as needed.

### Raster (24-Column)

A fixed 24-column grid suitable for complex layouts:

```html
<div class="as-raster">
    <div class="use-raster" style="--span-x: 12">Half width</div>
    <div class="use-raster" style="--span-x: 12">Half width</div>
</div>
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--raster-x` | 24 | Column count |
| `--raster-y` | 1 | Row count |
| `--gap` | `var(--unit)` | Gap size |
| `--gap-x` | `var(--gap)` | Column gap |
| `--gap-y` | `var(--gap)` | Row gap |

### Grid (Flexible)

A user-defined grid for simpler layouts:

```html
<div class="as-grid" style="--columns: 3">
    <div class="use-grid">Item 1</div>
    <div class="use-grid">Item 2</div>
    <div class="use-grid">Item 3</div>
</div>
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--columns` | 1 | Number of columns |
| `--rows` | 1 | Number of rows |

### Grid Item Variables

Both grid systems support the same item-level variables:

```css
.use-raster, .use-grid {
    --start-x: auto;     /* Starting column */
    --start-y: auto;     /* Starting row */
    --span-x: 1;         /* Columns to span */
    --span-y: 1;         /* Rows to span */
    --align-x: stretch;  /* Horizontal alignment */
    --align-y: stretch;  /* Vertical alignment */
}
```

### Bento Layout Example

```html
<div class="as-grid" style="--columns: 4; --rows: 3; --gap: 1rem">
    <div class="use-grid" style="--span-x: 2; --span-y: 2">Feature</div>
    <div class="use-grid">Item</div>
    <div class="use-grid" style="--span-y: 2">Sidebar</div>
    <div class="use-grid" style="--span-x: 3">Footer</div>
</div>
```

---

## Semantic Wrappers

Semantic HTML elements default to grid display with appropriate gaps:

```css
section, main, aside, nav, header, footer {
    display: grid;
    gap: var(--unit);
}

article {
    display: grid;
    gap: calc(var(--unit) * 6);
}
```

This provides consistent vertical rhythm without additional classes.

---

## Typography

### Headings

| Element | Size | Weight | Notes |
|---------|------|--------|-------|
| h1 | 3rem | 600 | -- |
| h2 | 2.5rem | 600 | -- |
| h3 | 2rem | 500 | -- |
| h4 | 1.5rem | 500 | -- |
| h5 | 1rem | 400 | Uppercase, letter-spacing |
| h6 | 1rem | 400 | Underlined via border-bottom |

### Body Text

```css
p {
    line-height: var(--line-height-base);  /* 1.5 */
    margin-bottom: var(--unit);            /* 8px */
}
```

### Inline Elements

| Element | Styling |
|---------|---------|
| `a` | Accent colour, underline on hover |
| `small` | 0.875rem |
| `mark` | Highlight background |
| `ins` | Insertion background |
| `del` | Strikethrough, muted colour |
| `code` | Monospace with background |
| `kbd` | Keyboard key appearance |
| `abbr` | Dotted underline, help cursor |

### Code Blocks

```html
<pre><code>
    <span data-line>const x = 1;</span>
    <span data-line>const y = 2;</span>
</code></pre>
```

Line numbers appear automatically via CSS counters when using `data-line`
spans. The Metroline theme's JavaScript can add these spans automatically.

---

## Forms

### Text Inputs

All text-type inputs share consistent styling:

```css
input[type="text"],
input[type="email"],
input[type="password"],
input[type="search"],
input[type="tel"],
input[type="url"],
input[type="number"],
input[type="date"],
input[type="time"],
input[type="datetime-local"],
textarea,
select { /* shared styles */ }
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--input-border-width` | 1px | Border width |
| `--input-border` | `var(--border)` | Border colour |
| `--input-radius` | 10px | Corner radius |
| `--input-background` | `var(--control)` | Background colour |
| `--input-color` | `var(--text)` | Text colour |

### Buttons

```html
<button>Primary</button>
<button class="is-secondary">Secondary</button>
<button disabled>Disabled</button>
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--button-weight` | 500 | Font weight |
| `--button-radius` | 12px | Corner radius |
| `--button-background` | `var(--accent)` | Primary background |
| `--button-color` | `var(--text-inv)` | Primary text colour |
| `--button-secondary-background` | `var(--control)` | Secondary background |
| `--button-secondary-color` | `var(--text)` | Secondary text colour |

### Checkbox (Toggle Switch)

Checkboxes render as iOS-style toggle switches (51x31 pixels).

### Radio Buttons

Custom circular radio buttons (24 pixels) with an inner dot on selection.

### Range Slider

```html
<input type="range" min="0" max="100" value="50" style="--value: 50">
```

The `--value` variable must be set via JavaScript to display the fill colour
correctly. Without it, the track appears unfilled.

### Dual Range Slider

```html
<div class="as-range-dual" style="--min: 20; --max: 80">
    <input type="range" min="0" max="100" value="20">
    <input type="range" min="0" max="100" value="80">
</div>
```

### Progress and Meter

```html
<progress value="70" max="100"></progress>
<meter value="0.6" low="0.3" high="0.7" optimum="0.8"></meter>
```

### Password Field with Toggle

```html
<div class="as-password">
    <input type="password" id="pw">
    <input type="checkbox" id="show-pw">
    <label for="show-pw"></label>
</div>
```

Uses `-webkit-text-security` for show/hide toggle without JavaScript.

### Search Field

```html
<form class="as-search">
    <input type="search" placeholder="Search...">
    <button type="submit">Search</button>
</form>
```

Includes a progress bar controllable via the `--progress` variable (0--100).

### Segments (Pill Toggle)

```html
<div class="as-segments">
    <input type="radio" name="seg" id="s1" checked>
    <label for="s1">Option 1</label>
    <input type="radio" name="seg" id="s2">
    <label for="s2">Option 2</label>
</div>
```

### Tabs

```html
<div class="as-tabs" style="--tab-count: 3">
    <input type="radio" name="tabs" id="t1" checked>
    <label for="t1">Tab 1</label>
    <div class="as-panel">Content 1</div>

    <input type="radio" name="tabs" id="t2">
    <label for="t2">Tab 2</label>
    <div class="as-panel">Content 2</div>
</div>
```

Add `like-vertical` for vertical tab orientation.

---

## Components

### Card

```html
<div class="as-card">
    <header>Title</header>
    <div>Content</div>
    <footer>Actions</footer>
</div>
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--card-border-width` | 1px | Border width |
| `--card-border` | `var(--border)` | Border colour |
| `--card-radius` | 16px | Corner radius |
| `--card-background` | `var(--surface)` | Background colour |

Add `show-shadow` for a drop shadow. Add `has-hover` for a lift effect on hover.

### Alert

```html
<div class="as-alert is-warning">
    <p>Warning message here.</p>
</div>
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `--alert-height` | 64px | Minimum height |
| `--alert-border-width` | 4px | Left border width |
| `--alert-radius` | 8px | Corner radius |

### Accordion

```html
<div class="as-accordion">
    <details>
        <summary>Section Title</summary>
        <div class="content">Content here</div>
    </details>
</div>
```

### Avatar

```html
<div class="as-avatar" style="--size: 40px">
    <img src="user.jpg" alt="User">
</div>
<div class="as-avatar">AB</div>
```

### Badge

```html
<span class="as-badge">Default</span>
<span class="as-badge is-success">Success</span>
```

### Counter

```html
<span class="as-counter" style="--count: 5">Notifications</span>
```

The counter hides automatically when `--count` is 0 or unset.

### Chip

```html
<span class="as-chip">
    Tag
    <button aria-label="Remove">&times;</button>
</span>
```

### Breadcrumb

```html
<nav class="as-breadcrumb">
    <ol>
        <li><a href="/">Home</a></li>
        <li><a href="/products">Products</a></li>
        <li>Current</li>
    </ol>
</nav>
```

Add `like-pills` for pill-style breadcrumbs.

### Tooltip

```html
<button class="has-tooltip" data-cn-tooltip="Helpful text">
    Hover me
</button>
```

Position with `style="--anchor: bottom"` (or `left`, `right`).

### Dropdown

```html
<details class="as-dropdown-trigger">
    <summary>Menu</summary>
    <ul class="as-dropdown">
        <li>Option 1</li>
        <li class="as-divider"></li>
        <li>Option 2</li>
    </ul>
</details>
```

### Dialog

```html
<dialog>
    <h3>Dialog Title</h3>
    <p>Dialog content</p>
    <button onclick="this.closest('dialog').close()">Close</button>
</dialog>
```

### Toast

```html
<div class="as-toast-container">
    <div class="as-toast is-success">Message saved!</div>
</div>
```

Position with `style="--anchor: top"`. Auto-width with `style="--width: auto"`.

### Pagination

```html
<nav class="as-pagination">
    <div><a href="#">&larr;</a></div>
    <div style="--align-x: center">
        <a href="#">1</a>
        <a href="#" aria-current="page">2</a>
        <span>&hellip;</span>
        <a href="#">10</a>
    </div>
    <div style="--align-x: end"><a href="#">&rarr;</a></div>
</nav>
```

### Skeleton Loading

```html
<div class="is-loading" style="width: 200px; height: 20px; border-radius: 4px"></div>
```

Any element with `is-loading` displays a shimmer animation.

### Progress Button

```html
<div class="as-progress-button">
    <button>Hold to confirm</button>
</div>
```

### Wizard

```html
<div class="as-wizard">
    <section>
        <div>Step 1</div>
        <div inert>Step 2</div>
        <div inert>Step 3</div>
    </section>
    <footer>
        <nav>
            <button aria-selected="true"></button>
            <button></button>
            <button></button>
        </nav>
    </footer>
</div>
```

---

## State Modifiers

```css
.is-info    { --state-bg: var(--info);    --state-border: var(--info);    --state-color: var(--text-inv); }
.is-success { --state-bg: var(--success); --state-border: var(--success); --state-color: var(--text-inv); }
.is-warning { --state-bg: var(--warning); --state-border: var(--warning); --state-color: var(--text-inv); }
.is-error   { --state-bg: var(--error);   --state-border: var(--error);   --state-color: var(--text-inv); }
```

Apply to any component:

```html
<div class="as-alert is-success">Success!</div>
<span class="as-badge is-error">Error</span>
```

---

## State Handling

Native HTML attributes take priority over classes. The `.is-*` classes provide
a readable alternative and cover states without native equivalents.

| State | Native Attribute | Class | Priority |
|-------|------------------|-------|----------|
| Disabled | `[disabled]` | `.is-disabled` | Attribute wins |
| Open | `[open]` | `.is-open` | Attribute wins |
| Checked | `:checked` | `.is-checked` | Pseudo-class wins |
| Loading | -- | `.is-loading` | Class (no native) |
| Error | -- | `.is-error` | Class (no native) |

**Principle:** Use native attributes where they exist. Use `.is-*` classes for
readability or for states without native equivalents.

---

## Variable Cascade

Variables follow a three-level cascade:

1. **State** -- `--state-bg` (from `.is-error`, `.is-success`, etc.)
2. **Component** -- `--badge-background` (component-specific)
3. **Theme** -- `--control` (global default)

```css
.as-badge {
    background: var(--state-bg, var(--badge-background, var(--control)));
}
```

This cascade provides precise control at every level whilst maintaining
sensible defaults.

---

## Theme Variables

```css
:root {
    /* Surfaces */
    --bg:       light-dark(oklch(97% 0 0),  oklch(15% 0 0));
    --surface:  light-dark(oklch(100% 0 0), oklch(22% 0 0));
    --control:  light-dark(oklch(92% 0 0),  oklch(28% 0 0));

    /* Text */
    --text:     light-dark(oklch(15% 0 0),  oklch(97% 0 0));
    --text-inv: light-dark(oklch(100% 0 0), oklch(100% 0 0));
    --muted:    light-dark(oklch(60% 0 0),  oklch(65% 0 0));

    /* Borders */
    --border:   light-dark(oklch(85% 0 0),  oklch(30% 0 0));

    /* Accents */
    --accent:   oklch(55% 0.22 260);
    --info:     oklch(65% 0.15 230);
    --success:  oklch(65% 0.2 145);
    --warning:  oklch(70% 0.18 85);
    --error:    oklch(55% 0.25 25);

    /* Utilities */
    --shadow-sm: light-dark(oklch(0% 0 0 / 0.1), oklch(0% 0 0 / 0.2));
}
```

---

## Browser Support

| Feature | Blink | Gecko | WebKit |
|---------|-------|-------|--------|
| CSS Nesting | 120+ | 117+ | 17.2+ |
| @property | 85+ | 128+ | 15.4+ |
| light-dark() | 123+ | 120+ | 17.5+ |
| OKLCH | 111+ | 113+ | 15.4+ |

---

## See Also

- Theming: [09-theming.md](09-theming.md)
- Scripting: [08-scripting.md](08-scripting.md)
- Concepts: [03-concepts.md](03-concepts.md)

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
