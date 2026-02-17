# Concepts

This document explains the design principles behind CASTD. Understanding
these concepts will help you use the framework effectively and extend it
predictably.

---

## Accessibility

CASTD is WCAG 2.2 AA compliant out of the box.

### What This Means in Practice

- All colour combinations meet minimum contrast ratios (4.5:1 for text, 3:1 for UI elements)
- Focus states are visible and consistent across all interactive elements
- Semantic HTML receives appropriate styling
- Form controls support proper labelling
- Interactive components respond to keyboard navigation
- Information is never conveyed by colour alone

When you customise colours, you assume responsibility for maintaining these
standards. The framework cannot validate your choices, but it provides tools
(OKLCH colour space, documented contrast ratios) to make compliance
straightforward.

---

## Class Naming

CASTD uses a prefix system that communicates intent at a glance.

### Why Prefixes Matter

**Self-documenting** — Reading `as-card show-shadow has-hover` tells you
exactly what the element is, what it displays, and how it behaves.

**Predictable** — The same prefix carries the same meaning across all
components. Every `is-*` class indicates state. Every `show-*` class
enables a visual feature.

**Conflict-free** — Prefixed classes do not collide with your own naming
conventions or with other libraries.

### The Five Prefixes

| Prefix | Meaning | Description |
|--------|---------|-------------|
| `as-*` | Structure | What the element fundamentally is |
| `is-*` | State | A dynamic condition |
| `like-*` | Variant | An alternative layout |
| `show-*` | Feature | An opt-in visual |
| `has-*` | Capability | An interactive behaviour |

---

### Structure: `as-*`

Structure classes define the fundamental nature of an element. They establish
layout, spacing, and semantic meaning.

```html
<article class="as-card">...</article>
<nav class="as-breadcrumb">...</nav>
<span class="as-badge">...</span>
```

A card remains a card regardless of its colour, shadow, or hover state. The
structure is constant; appearance varies.

---

### State: `is-*`

State classes reflect dynamic conditions that change based on data or user
interaction.

```html
<span class="as-badge is-success">Approved</span>
<span class="as-badge is-error">Rejected</span>
<input type="text" class="is-error">
<p class="is-loading">Loading content...</p>
```

States are semantic. An error badge communicates meaning, not merely colour.
Screen readers and automated tests can interpret state classes meaningfully.

**Available states:**

| Class | Purpose |
|-------|---------|
| `is-info` | Informational content |
| `is-success` | Positive outcome |
| `is-warning` | Caution required |
| `is-error` | Negative outcome or invalid input |
| `is-loading` | Content is loading (displays shimmer) |
| `is-secondary` | Reduced emphasis |

---

### Variant: `like-*`

Variant classes provide alternative layouts for the same component. The
component's purpose remains unchanged; only its arrangement differs.

```html
<div class="as-tabs">...</div>
<div class="as-tabs like-vertical">...</div>

<nav class="as-breadcrumb">...</nav>
<nav class="as-breadcrumb like-pills">...</nav>
```

---

### Feature: `show-*`

Visual features are off by default. Use `show-*` to enable them explicitly.

```html
<article class="as-card">Plain card</article>
<article class="as-card show-shadow">Card with shadow</article>
```

CASTD defaults to minimal. Shadows, borders, and decorative elements
require deliberate inclusion. This prevents visual clutter and keeps the
default output clean.

---

### Capability: `has-*`

Capability classes add interactive features that affect behaviour on user
interaction.

```html
<article class="as-card show-shadow has-hover">Lifts on hover</article>
<button class="has-tooltip" data-cn-tooltip="Save changes">Save</button>
```

Capabilities typically require additional attributes or JavaScript enhancement.

---

## CSS Variables

Customisation happens through CSS custom properties, not additional classes.

### Why Variables Instead of Classes

**No class explosion** — Without variables, you would need classes like
`.card-blue`, `.card-large`, `.card-rounded`. Variables eliminate this
proliferation.

**Infinite variations** — Any value, any combination, without writing new CSS.

**Scoped changes** — Override a variable on one element without affecting
others.

**Theme inheritance** — Change a colour once in `:root` and everything updates.

---

### Component Variables

Each component defines its own variables with sensible defaults:

```css
.as-card {
    background: var(--card-background, var(--surface));
    border: var(--card-border-width, 1px) solid var(--card-border, var(--border));
    border-radius: var(--card-radius, 1rem);
}
```

Override inline for one-off changes:

```html
<article class="as-card" style="--card-radius: 0;">
    Square corners on this card only.
</article>
```

Or override in your stylesheet for global changes:

```css
.as-card {
    --card-radius: 0;
}
```

---

### Theme Variables

Global theme variables control the overall appearance:

```css
:root {
    --bg: oklch(5% 0.02 280);
    --surface: oklch(15% 0.02 280);
    --text: oklch(90% 0 0);
    --accent: oklch(55% 0.25 265);
}
```

Components inherit these automatically. Change the theme variables and every
component updates accordingly.

---

## CSS Layers

CASTD uses CSS `@layer` for predictable specificity.

### Why Layers Matter

**No specificity wars** — Layers have defined priority independent of selector
complexity. A simple selector in a higher layer beats a complex selector in a
lower layer.

**Safe overrides** — Your styles naturally override framework styles without
requiring `!important`.

**Clean separation** — Structure, components, and theme are isolated from
each other.

### Layer Order

```css
@layer globals, castd, theme;
```

| Layer | Purpose | Author |
|-------|---------|--------|
| `globals` | HTML reset, base elements | Framework (immutable) |
| `castd` | Components, presets, Metroline | Framework + Presets |
| `theme` | Customer overrides | You |

Your styles come after `castd` and naturally override it. For explicit
control, declare your own layer:

```css
@layer globals, castd, theme, custom;

@layer custom {
    .as-card {
        --card-radius: 0;
    }
}
```

---

## Light and Dark Mode

CASTD uses the `light-dark()` CSS function for automatic theme switching.

```css
:root {
    --bg: light-dark(oklch(97% 0 0), oklch(15% 0 0));
    --text: light-dark(oklch(15% 0 0), oklch(97% 0 0));
}
```

### Benefits

**Zero JavaScript** — The browser handles mode switching natively.

**Respects user preference** — Works with system settings automatically.

**Single definition** — One variable declaration serves both modes.

Enable automatic switching with the colour-scheme meta tag:

```html
<meta name="color-scheme" content="light dark">
```

---

## File Naming

Every file is named after its containing folder:

```
button/button.html       ✓ Correct
button/index.html        ✗ Wrong
button/template.html     ✗ Wrong
```

This convention applies to templates, presets, and all associated files
(`.html`, `.css`, `.js`, `.csv`). It eliminates ambiguity and makes the
codebase navigable without configuration files.

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
