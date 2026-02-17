# cn:preset.layout.grid

Flexible CSS grid container.

## Usage

```html
{( cn:preset.layout.grid columns="3" content="
    <div>Column 1</div>
    <div>Column 2</div>
    <div>Column 3</div>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Grid items (supports HTML) |
| `columns` | number | `1` | Number of columns (`--columns`) |
| `gap` | string | — | Gap between items (`--gap`) |
| `style` | string | — | Additional inline styles |

## Output

```html
<div class="as-grid" style="--columns: 3">
    <div>Column 1</div>
    <div>Column 2</div>
    <div>Column 3</div>
</div>
```

## Styling

Grid styling is provided by `castd.css`.

### CSS Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `--columns` | `1` | Number of columns |
| `--gap` | `1rem` | Gap between items |

## Examples

### Two Columns

```html
{( cn:preset.layout.grid columns="2" content="
    <div>Left</div>
    <div>Right</div>
" )}
```

### Three Column Cards

```html
{( cn:preset.layout.grid columns="3" gap="2rem" content="
    {( cn:preset.ui.card header='Plan A' content='<p>Basic</p>' footer='£9/mo' )}
    {( cn:preset.ui.card header='Plan B' content='<p>Pro</p>' footer='£19/mo' )}
    {( cn:preset.ui.card header='Plan C' content='<p>Enterprise</p>' footer='Contact' )}
" )}
```

### Four Column Feature Grid

```html
{( cn:preset.layout.grid columns="4" content="
    <div><h3>🚀 Fast</h3><p>Lightning quick</p></div>
    <div><h3>🔒 Secure</h3><p>Enterprise grade</p></div>
    <div><h3>📱 Responsive</h3><p>Works everywhere</p></div>
    <div><h3>♿ Accessible</h3><p>WCAG compliant</p></div>
" )}
```

### Custom Gap

```html
{( cn:preset.layout.grid columns="2" gap="3rem" content="
    <div>Wide gap</div>
    <div>Between items</div>
" )}
```

### Responsive Grid

The grid automatically responds to viewport width. For custom breakpoints:

```html
{( cn:preset.layout.grid 
    columns="4" 
    style="--columns: 1; @media (min-width: 600px) { --columns: 2 }; @media (min-width: 900px) { --columns: 4 }" 
    content="..." 
)}
```

Or use CSS:

```css
.as-grid {
    --columns: 1;
}

@media (min-width: 600px) {
    .as-grid { --columns: 2; }
}

@media (min-width: 900px) {
    .as-grid { --columns: 4; }
}
```

### Spanning Items

For items that span multiple columns:

```html
{( cn:preset.layout.grid columns="3" content="
    <div>Item 1</div>
    <div>Item 2</div>
    <div>Item 3</div>
    <div style='grid-column: span 2'>Wide item</div>
    <div>Item 5</div>
" )}
```

## See Also

- [cn:preset.layout.container](container.md) — Width constraint
- [cn:preset.ui.card](../ui/card.md) — Card component

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
