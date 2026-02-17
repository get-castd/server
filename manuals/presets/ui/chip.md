# cn:preset.ui.chip

Interactive chip for tags, filters, or selections.

## Usage

```html
{( cn:preset.ui.chip label="JavaScript" removable=true )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | **Required** | Chip text |
| `removable` | boolean | — | Show remove button |
| `selected` | boolean | — | Selected state |
| `disabled` | boolean | — | Disabled state |
| `icon` | string | — | Leading icon (HTML) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<span class="as-chip">
    <span class="chip-label">JavaScript</span>
    <button type="button" class="chip-remove" aria-label="Remove JavaScript">×</button>
</span>
```

## Styling

Chip styling is provided by `chip.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--chip-bg` | Background colour |
| `--chip-color` | Text colour |
| `--chip-border` | Border colour |
| `--chip-radius` | Border radius |
| `--chip-selected-bg` | Selected background |
| `--chip-selected-color` | Selected text colour |

## Examples

### Basic Chip

```html
{( cn:preset.ui.chip label="Tag" )}
```

### Removable Chips

```html
<div class="chip-group">
    {( cn:preset.ui.chip label="React" removable=true )}
    {( cn:preset.ui.chip label="Vue" removable=true )}
    {( cn:preset.ui.chip label="Angular" removable=true )}
</div>
```

### With Icon

```html
{( cn:preset.ui.chip icon="🏷️" label="Category" )}
```

### Selected State

```html
{( cn:preset.ui.chip label="Active Filter" selected=true )}
```

### Disabled

```html
{( cn:preset.ui.chip label="Unavailable" disabled=true )}
```

## JavaScript: Remove Handler

```javascript
document.querySelectorAll('.chip-remove').forEach(btn => {
    btn.addEventListener('click', () => {
        btn.closest('.as-chip').remove();
    });
});
```

## Chip vs Badge

| Component | Use Case |
|-----------|----------|
| Badge | Static label, count, or status |
| Chip | Interactive tag, filter, or selection |

## See Also

- [cn:preset.ui.badge](badge.md) — Static badges
- [cn:preset.ui.avatar](avatar.md) — User avatars

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
