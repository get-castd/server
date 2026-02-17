# Theming

CASTD uses the OKLCH colour space and CSS custom properties for all theming.
The default theme, Metroline, provides a neutral foundation that works in
both light and dark mode.

---

## OKLCH Colour Space

OKLCH (Oklab Lightness, Chroma, Hue) provides several advantages over
traditional colour spaces:

**Perceptual uniformity** — Equal numerical steps produce equal perceived
differences. A 10% change in lightness looks like a 10% change, regardless
of hue.

**Predictable lightness** — Unlike HSL, where "50% lightness" varies wildly
between hues, OKLCH lightness is consistent across the spectrum.

**Consistent chroma** — Saturation is independent of hue. A chroma of 0.2
produces comparable vibrancy whether the hue is red or blue.

**Wide gamut support** — OKLCH naturally supports P3 and wider gamuts without
clamping or approximation.

### Syntax

```css
oklch(lightness chroma hue)
oklch(55% 0.22 260)
/*    │      │    └── Hue angle (0–360)
      │      └─────── Chroma (0–0.4 typical)
      └────────────── Lightness (0–100%)
*/
```

### Hue Reference

| Hue | Colour |
|-----|--------|
| 0° | Red |
| 30° | Orange |
| 60° | Yellow |
| 120° | Green |
| 180° | Cyan |
| 240° | Blue |
| 300° | Magenta |

### Choosing Values

| Component | Range | Guidelines |
|-----------|-------|------------|
| Lightness | 0–100% | 50–70% for accent colours |
| Chroma | 0–0.4 | 0.15–0.25 for vivid colours |
| Hue | 0–360° | See reference above |

---

## Colour Palette

### Surface Colours

```css
--bg:       light-dark(oklch(97% 0 0),  oklch(15% 0 0));
--surface:  light-dark(oklch(100% 0 0), oklch(22% 0 0));
--control:  light-dark(oklch(92% 0 0),  oklch(28% 0 0));
```

| Variable | Light Mode | Dark Mode | Purpose |
|----------|------------|-----------|---------|
| `--bg` | 97% white | 15% dark | Page background |
| `--surface` | Pure white | 22% dark | Elevated surfaces (cards, dialogues) |
| `--control` | 92% grey | 28% dark | Form controls |

### Text Colours

```css
--text:     light-dark(oklch(15% 0 0),  oklch(97% 0 0));
--text-inv: light-dark(oklch(100% 0 0), oklch(100% 0 0));
--muted:    light-dark(oklch(60% 0 0),  oklch(65% 0 0));
```

| Variable | Light Mode | Dark Mode | Purpose |
|----------|------------|-----------|---------|
| `--text` | 15% dark | 97% light | Primary text |
| `--text-inv` | White | White | Text on coloured backgrounds |
| `--muted` | 60% grey | 65% grey | Secondary text, captions |

### Border Colour

```css
--border: light-dark(oklch(85% 0 0), oklch(30% 0 0));
```

### Accent Colours

```css
--accent:   oklch(55% 0.22 260);   /* Purple — primary actions */
--info:     oklch(65% 0.15 230);   /* Blue — informational */
--success:  oklch(65% 0.2 145);    /* Green — positive */
--warning:  oklch(70% 0.18 85);    /* Amber — caution */
--error:    oklch(55% 0.25 25);    /* Red — negative */
```

| Variable | Hue | Purpose |
|----------|-----|---------|
| `--accent` | 260° (purple) | Primary actions, links, focus states |
| `--info` | 230° (blue) | Informational messages |
| `--success` | 145° (green) | Positive outcomes, confirmations |
| `--warning` | 85° (amber) | Warnings, non-critical issues |
| `--error` | 25° (red) | Errors, destructive actions |

---

## Light and Dark Mode

The `light-dark()` function automatically switches values based on the
user's colour scheme preference:

```css
--bg: light-dark(oklch(97% 0 0), oklch(15% 0 0));
/*               │               └── Dark mode value
                 └─────────────────── Light mode value
*/
```

### Enabling Automatic Switching

```html
<meta name="color-scheme" content="light dark">
```

This meta tag tells the browser to respect `prefers-color-scheme`.

### Benefits

**Zero JavaScript** — The browser handles mode switching natively.

**System preference** — Respects the user's operating system setting.

**Single definition** — One variable declaration serves both modes.

---

## Metroline Theme

### Overview

Metroline is CASTD's default theme. It defines the visual appearance through
CSS custom properties and provides the foundation for all framework
components. The server injects it automatically when no custom theme is
specified.

### Theme Files

Located at `castd/frontend/presets/themes/metroline/`:

```
metroline/
├── metroline.css    # Reserved for theme-specific CSS overrides (currently empty)
└── metroline.js     # Theme-specific JavaScript (code block line numbers)
```

### Automatic Injection

When Metroline is active, both files are automatically injected:

- `metroline.css` — After `castd.css` (placeholder for future overrides)
- `metroline.js` — After `castd.js`

No manual preset calls needed for the default theme.

### Design Tokens

All default design tokens are defined in `castd.css @layer theme`, not in
`metroline.css`. Metroline inherits these base tokens and could override
them in `metroline.css` if needed, but currently uses all defaults as-is.

#### Typography Scale

```css
:root {
    --line-height-tight: 1.25;  /* Headings */
    --line-height-base: 1.5;    /* Body text */
}
```

| Element | Size | Weight | Notes |
|---------|------|--------|-------|
| h1 | 3rem (48px) | 600 | — |
| h2 | 2.5rem (40px) | 600 | — |
| h3 | 2rem (32px) | 500 | — |
| h4 | 1.5rem (24px) | 500 | — |
| h5 | 1rem (16px) | 400 | Uppercase |
| h6 | 1rem (16px) | 400 | Underlined |
| p | 1rem (16px) | 400 | line-height: 1.5 |
| small | 0.875rem (14px) | 400 | — |
| code | 0.875rem (14px) | 400 | Monospace |

#### Component Tokens

**Buttons:**

```css
--button-weight: 500;
--button-radius: calc(var(--unit) * 1.5);      /* 12px */
--button-background: var(--accent);
--button-color: var(--text-inv);
```

**Inputs:**

```css
--input-border-width: 1px;
--input-border: var(--border);
--input-radius: calc(var(--unit) * 1.25);      /* 10px */
--input-background: var(--control);
```

**Cards:**

```css
--card-border-width: 1px;
--card-border: var(--border);
--card-radius: calc(var(--unit) * 2);          /* 16px */
--card-background: var(--surface);
```

**Other:**

```css
--dialog-radius: var(--unit);                  /* 8px */
--alert-radius: var(--unit);                   /* 8px */
--toast-radius: calc(var(--unit) * 1.5);       /* 12px */
--tooltip-radius: calc(var(--unit) * 0.75);    /* 6px */
```

### Code Block Line Numbers

`metroline.js` wraps each line in `<pre><code>` blocks with
`<span data-line>`:

```javascript
// Input:
<pre><code>const x = 1;
const y = 2;</code></pre>

// Output after metroline.js:
<pre><code><span data-line>const x = 1;</span>
<span data-line>const y = 2;</span>
</code></pre>
```

The CSS in `castd.css` styles these spans:

```css
pre code span[data-line] {
    display: grid;
    grid-template-columns: calc(var(--unit) * 4) 1fr;
    gap: calc(var(--unit) * 2);

    &::before {
        content: counter(line);
        counter-increment: line;
        text-align: right;
        user-select: none;
        color: var(--muted);
    }
}
```

The result: line numbers in a left gutter, non-selectable, with hover
highlighting.

---

## Theme Hierarchy

```
┌─────────────────────────────────────────────────┐
│  4. Bundle Theme (from Store or custom)         │  ← Highest priority
├─────────────────────────────────────────────────┤
│  3. Customer Theme (workspace/{bundle}/presets) │
├─────────────────────────────────────────────────┤
│  2. Metroline Theme (auto-injected)             │  ← Default
├─────────────────────────────────────────────────┤
│  1. castd.css @layer theme                      │  ← Base tokens
└─────────────────────────────────────────────────┘
```

Each layer can override the previous.

---

## Creating Custom Themes

### Location

```
workspace/{bundle}/presets/themes/{name}/
├── {name}.css
└── {name}.js     # Optional
```

### Override Pattern

```css
@layer theme {
    :root {
        --accent: oklch(55% 0.22 280);
        --button-radius: 0;
    }
}
```

### Single Variable Override

```css
@layer theme {
    :root {
        --accent: oklch(60% 0.25 180);  /* Teal */
    }
}
```

### Full Custom Theme

```css
/* my-theme.css */
@layer theme {
    :root {
        --bg: oklch(5% 0.02 280);
        --surface: oklch(15% 0.02 280);
        --accent: oklch(70% 0.15 195);
    }
}
```

### Brand Colour Example

```css
/* Corporate teal */
--brand: oklch(55% 0.18 180);

/* Apply as accent */
@layer theme {
    :root {
        --accent: var(--brand);
    }
}
```

---

## CSS Variable Reference

### Base Unit

```css
--unit: 0.5rem;  /* 8px at default font size */
```

All spacing derives from this unit:

| Expression | Pixels | Common Use |
|------------|--------|------------|
| `var(--unit)` | 8 | Small gaps |
| `calc(var(--unit) * 2)` | 16 | Standard padding |
| `calc(var(--unit) * 3)` | 24 | Section spacing |
| `calc(var(--unit) * 4)` | 32 | Large spacing |
| `calc(var(--unit) * 6)` | 48 | Article gaps |

### Typography

```css
--line-height-tight: 1.25;   /* Headings */
--line-height-base: 1.5;     /* Body text */
```

#### Headings

| Variable | Default |
|----------|---------|
| `--h1-size` | 3rem |
| `--h1-weight` | 600 |
| `--h2-size` | 2.5rem |
| `--h2-weight` | 600 |
| `--h3-size` | 2rem |
| `--h3-weight` | 500 |
| `--h4-size` | 1.5rem |
| `--h4-weight` | 500 |
| `--h5-size` | 1rem |
| `--h5-weight` | 400 |
| `--h6-size` | 1rem |
| `--h6-weight` | 400 |

#### Text

| Variable | Default |
|----------|---------|
| `--small-size` | 0.875rem |
| `--code-size` | 0.875rem |
| `--label-size` | 0.875rem |
| `--label-weight` | 500 |

### Surfaces

```css
--bg:       light-dark(oklch(97% 0 0),  oklch(15% 0 0));
--surface:  light-dark(oklch(100% 0 0), oklch(22% 0 0));
--control:  light-dark(oklch(92% 0 0),  oklch(28% 0 0));
--border:   light-dark(oklch(85% 0 0),  oklch(30% 0 0));
```

### Text

```css
--text:     light-dark(oklch(15% 0 0),  oklch(97% 0 0));
--text-inv: light-dark(oklch(100% 0 0), oklch(100% 0 0));
--muted:    light-dark(oklch(60% 0 0),  oklch(65% 0 0));
```

### Semantic Colours

```css
--accent:   oklch(55% 0.22 260);
--info:     oklch(65% 0.15 230);
--success:  oklch(65% 0.2 145);
--warning:  oklch(70% 0.18 85);
--error:    oklch(55% 0.25 25);
```

### Utilities

```css
--shadow-sm: light-dark(oklch(0% 0 0 / 0.1), oklch(0% 0 0 / 0.2));
--stripe:    light-dark(oklch(0% 0 0 / 0.05), oklch(100% 0 0 / 0.05));
--disabled:  repeating-linear-gradient(...);

--mark-background: light-dark(oklch(85% 0.15 85), oklch(50% 0.2 60));
--mark-color:      light-dark(oklch(20% 0 0), oklch(95% 0 0));
--ins-background:  light-dark(oklch(90% 0.1 145), oklch(45% 0.2 140));
--ins-color:       light-dark(oklch(20% 0 0), oklch(95% 0 0));
--code-color:      oklch(75% 0.12 70);
```

### State Variables

Set automatically by `.is-*` classes:

```css
--state-bg:     /* Background colour */
--state-border: /* Border colour */
--state-color:  /* Text colour */
```

### Form Variables

#### Inputs

| Variable | Default |
|----------|---------|
| `--input-border-width` | 1px |
| `--input-border` | `var(--border)` |
| `--input-radius` | 10px |
| `--input-background` | `var(--control)` |
| `--input-color` | `var(--text)` |

#### Buttons

| Variable | Default |
|----------|---------|
| `--button-weight` | 500 |
| `--button-radius` | 12px |
| `--button-background` | `var(--accent)` |
| `--button-color` | `var(--text-inv)` |
| `--button-secondary-background` | `var(--control)` |
| `--button-secondary-color` | `var(--text)` |

#### Checkbox

| Variable | Default |
|----------|---------|
| `--checkbox-background` | `var(--control)` |

#### Radio

| Variable | Default |
|----------|---------|
| `--radio-border` | `var(--border)` |
| `--radio-background` | `var(--control)` |

#### File Input

| Variable | Default |
|----------|---------|
| `--file-border` | `var(--border)` |
| `--file-background` | `var(--control)` |
| `--file-color` | `var(--text)` |

#### Progress

| Variable | Default |
|----------|---------|
| `--progress-background` | `var(--control)` |
| `--progress-fill` | `var(--accent)` |

#### Meter

| Variable | Default |
|----------|---------|
| `--meter-background` | `var(--control)` |
| `--meter-optimum` | `var(--success)` |
| `--meter-suboptimum` | `var(--warning)` |
| `--meter-low` | `var(--error)` |

#### Segments

| Variable | Default |
|----------|---------|
| `--segments-background` | `var(--control)` |
| `--segments-active` | `var(--surface)` |

#### Tabs

| Variable | Default |
|----------|---------|
| `--tabs-background` | transparent |
| `--tabs-color` | inherit |
| `--tabs-active-background` | transparent |
| `--tabs-active-color` | inherit |
| `--tabs-border` | `var(--border)` |
| `--tabs-radius` | 0 |

### Component Variables

#### Card

| Variable | Default |
|----------|---------|
| `--card-border-width` | 1px |
| `--card-border` | `var(--border)` |
| `--card-radius` | 16px |
| `--card-background` | `var(--surface)` |
| `--card-shadow` | `0 4px 16px oklch(0% 0 0 / 40%)` |
| `--card-hover-shadow` | `0 8px 24px oklch(0% 0 0 / 50%)` |

#### Alert

| Variable | Default |
|----------|---------|
| `--alert-height` | 64px |
| `--alert-border-width` | 4px |
| `--alert-border` | `var(--accent)` |
| `--alert-radius` | 8px |

#### Accordion

| Variable | Default |
|----------|---------|
| `--accordion-background` | `var(--surface)` |
| `--accordion-border-width` | 0 |
| `--accordion-border` | transparent |
| `--accordion-icon` | "+" |
| `--accordion-icon-open` | "−" |

#### Avatar

| Variable | Default |
|----------|---------|
| `--avatar-background` | `var(--control)` |
| `--avatar-color` | `var(--muted)` |
| `--avatar-border-width` | 0 |
| `--avatar-border` | transparent |

#### Badge

| Variable | Default |
|----------|---------|
| `--badge-radius` | 4px |
| `--badge-background` | `var(--control)` |
| `--badge-color` | `var(--text)` |

#### Chip

| Variable | Default |
|----------|---------|
| `--chip-radius` | 8px |
| `--chip-background` | `var(--control)` |
| `--chip-color` | `var(--text)` |

#### Counter

| Variable | Default |
|----------|---------|
| `--counter-radius` | 8px |
| `--counter-background` | `var(--error)` |
| `--counter-color` | `var(--text-inv)` |

#### Breadcrumb

| Variable | Default |
|----------|---------|
| `--breadcrumb-gap` | 4px |
| `--breadcrumb-separator` | "/" |
| `--breadcrumb-pill-radius` | 4px |
| `--breadcrumb-pill-border-width` | 0 |
| `--breadcrumb-pill-background` | `var(--control)` |
| `--breadcrumb-pill-hover` | `var(--surface)` |

#### Tooltip

| Variable | Default |
|----------|---------|
| `--tooltip-radius` | 6px |
| `--tooltip-border-width` | 0 |
| `--tooltip-background` | `var(--text)` |
| `--tooltip-color` | `var(--bg)` |

#### Dropdown

| Variable | Default |
|----------|---------|
| `--dropdown-border-width` | 1px |
| `--dropdown-border` | `var(--border)` |
| `--dropdown-radius` | 10px |
| `--dropdown-background` | `var(--control)` |
| `--dropdown-shadow` | none |
| `--dropdown-hover` | `var(--surface)` |

#### Dialogue

| Variable | Default |
|----------|---------|
| `--dialog-radius` | 8px |
| `--dialog-background` | `var(--surface)` |
| `--dialog-color` | `var(--text)` |

#### Toast

| Variable | Default |
|----------|---------|
| `--toast-radius` | 12px |
| `--toast-background` | `var(--info)` |
| `--toast-color` | `var(--text-inv)` |

#### Pagination

| Variable | Default |
|----------|---------|
| `--pagination-gap` | 4px |
| `--pagination-border-width` | 0 |
| `--pagination-radius` | 4px |
| `--pagination-background` | `var(--control)` |
| `--pagination-color` | `var(--text)` |
| `--pagination-hover` | `var(--surface)` |
| `--pagination-active` | `var(--accent)` |
| `--pagination-active-color` | `var(--text-inv)` |

#### Address

| Variable | Default |
|----------|---------|
| `--address-border` | `var(--muted)` |
| `--address-radius` | 16px |

#### Progress Button

| Variable | Default |
|----------|---------|
| `--progress-button-padding` | 3px |
| `--progress-button-color` | `var(--success)` |
| `--progress-button-duration` | 1s |

#### Wizard

| Variable | Default |
|----------|---------|
| `--wizard-padding` | 40px 32px 32px |
| `--wizard-footer-gap` | 20px |
| `--wizard-footer-padding` | 0 32px 32px |
| `--wizard-dots-gap` | 8px |
| `--wizard-dot-size` | 8px |
| `--wizard-dot-radius` | 4px |
| `--wizard-dot-background` | `var(--text-inv)` |
| `--wizard-dot-opacity` | 0.4 |
| `--wizard-dot-active-width` | 24px |
| `--wizard-dot-hover-opacity` | 0.7 |

### Code

| Variable | Default |
|----------|---------|
| `--code-radius` | 4px |
| `--pre-radius` | 8px |

### Blockquote

| Variable | Default |
|----------|---------|
| `--blockquote-border-width` | 4px |

### Details

| Variable | Default |
|----------|---------|
| `--details-icon` | "›" |

---

## Accessibility

### Contrast Requirements (WCAG 2.2 AA)

| Type | Minimum Ratio |
|------|---------------|
| Normal text | 4.5:1 |
| Large text (18px+) | 3:1 |
| UI components | 3:1 |

### CASTD Defaults

All default colour combinations meet or exceed these requirements:

| Combination | Contrast Ratio |
|-------------|----------------|
| `--text` on `--bg` | 12:1+ |
| `--text-inv` on `--accent` | 7:1+ |
| `--muted` on `--bg` | 4.5:1+ |

### Maintaining Compliance

When customising colours:

1. **Test contrast ratios** — Use a contrast checker tool
2. **Avoid relying on colour alone** — Supplement with icons, patterns, or text
3. **Test both modes** — Verify light and dark values separately

---

## Overriding Colours

### Single Component

```html
<article class="as-card" style="--card-background: oklch(95% 0.02 260);">
    Purple-tinted card
</article>
```

### Global Override

```css
@layer theme {
    :root {
        --accent: oklch(60% 0.25 180);  /* Teal accent */
    }
}
```

### Custom State

```css
.as-alert.is-custom {
    --state-bg: oklch(55% 0.2 300);
    --state-border: oklch(55% 0.2 300);
    --state-color: var(--text-inv);
}
```

---

## See Also

- Concepts: [03-concepts.md](03-concepts.md)
- Styling: [07-styling.md](07-styling.md)
- Presets: [10-presets.md](10-presets.md)

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
