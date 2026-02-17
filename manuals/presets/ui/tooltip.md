# cn:preset.ui.tooltip

Tooltip for displaying additional information on hover/focus.

## Usage

```html
{( cn:preset.ui.tooltip content="More information here" trigger="<button>?</button>" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Tooltip text |
| `trigger` | string | **Required** | Trigger element (HTML) |
| `position` | string | `"top"` | Position: `top`, `bottom`, `left`, `right` |
| `style` | string | — | Inline CSS styles |

## Output

```html
<span class="as-tooltip-trigger">
    <button>?</button>
    <span class="as-tooltip like-top" role="tooltip">More information here</span>
</span>
```

## Styling

Tooltip styling is provided by `tooltip.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--tooltip-bg` | Background colour |
| `--tooltip-color` | Text colour |
| `--tooltip-radius` | Border radius |
| `--tooltip-max-width` | Maximum width |
| `--tooltip-arrow-size` | Arrow dimensions |

### Position Variants

| Class | Position |
|-------|----------|
| (default) | Top |
| `like-bottom` | Bottom |
| `like-left` | Left |
| `like-right` | Right |

## Examples

### Basic Tooltip

```html
{( cn:preset.ui.tooltip 
    content="Click to save your changes" 
    trigger="<button>Save</button>" 
)}
```

### Position Variants

```html
{( cn:preset.ui.tooltip content="Top" position="top" trigger="<span>⬆</span>" )}
{( cn:preset.ui.tooltip content="Bottom" position="bottom" trigger="<span>⬇</span>" )}
{( cn:preset.ui.tooltip content="Left" position="left" trigger="<span>⬅</span>" )}
{( cn:preset.ui.tooltip content="Right" position="right" trigger="<span>➡</span>" )}
```

### Help Icon

```html
<label>
    Email
    {( cn:preset.ui.tooltip 
        content="We'll never share your email with anyone" 
        trigger="<span class='help-icon'>?</span>" 
    )}
</label>
<input type="email" name="email">
```

### Icon Button

```html
{( cn:preset.ui.tooltip 
    content="Delete item" 
    trigger="<button aria-label='Delete'>🗑️</button>" 
)}
```

## CSS-Only Implementation

Tooltips show on `:hover` and `:focus-within` — no JavaScript required.

## Accessibility

- Tooltip uses `role="tooltip"`
- Appears on both hover and focus
- Content should be supplementary, not essential

For essential information, use a different pattern (e.g., visible text).

## See Also

- [cn:preset.ui.dropdown](dropdown.md) — Dropdown menus
- [cn:preset.ui.dialog](dialog.md) — Modal dialogues

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
