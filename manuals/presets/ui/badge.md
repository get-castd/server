# cn:preset.ui.badge

Small label for status indicators, counts, or tags.

## Usage

```html
{( cn:preset.ui.badge label="New" state="success" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | **Required** | Badge text |
| `state` | string | — | Visual state: `info`, `success`, `warning`, `error` |
| `style` | string | — | Inline CSS styles |

## Output

```html
<span class="as-badge is-success">New</span>
```

## Styling

Badge styling is provided by `castd.css`.

### State Classes

| Class | Use Case |
|-------|----------|
| `is-info` | Informational |
| `is-success` | Positive/active |
| `is-warning` | Caution |
| `is-error` | Negative/inactive |

## Examples

### Status Badges

```html
{( cn:preset.ui.badge label="Active" state="success" )}
{( cn:preset.ui.badge label="Pending" state="warning" )}
{( cn:preset.ui.badge label="Inactive" state="error" )}
```

### Count Badge

```html
<button>
    Notifications {( cn:preset.ui.badge label="5" state="error" )}
</button>
```

### Version Badge

```html
{( cn:preset.ui.badge label="v2.1.0" state="info" )}
```

### Tags

```html
<div class="tags">
    {( cn:preset.ui.badge label="JavaScript" )}
    {( cn:preset.ui.badge label="CSS" )}
    {( cn:preset.ui.badge label="HTML" )}
</div>
```

### Custom Styling

```html
{( cn:preset.ui.badge 
    label="Pro" 
    style="--badge-bg: gold; --badge-color: black;" 
)}
```

## See Also

- [cn:preset.ui.chip](chip.md) — Interactive chip (planned)
- [cn:preset.ui.alert](alert.md) — Full alert messages

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
