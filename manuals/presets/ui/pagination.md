# cn:preset.ui.pagination

Page navigation for paginated content.

## Usage

```html
{( cn:preset.ui.pagination label="Results pagination" content="
    <a href='?page=1' class='pagination-first'>«</a>
    <a href='?page=2' class='pagination-prev'>‹</a>
    <a href='?page=1'>1</a>
    <a href='?page=2'>2</a>
    <a href='?page=3' aria-current='page'>3</a>
    <a href='?page=4'>4</a>
    <a href='?page=5'>5</a>
    <a href='?page=4' class='pagination-next'>›</a>
    <a href='?page=10' class='pagination-last'>»</a>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Pagination links (HTML) |
| `label` | string | `"Pagination"` | Accessible label |
| `style` | string | — | Inline CSS styles |

## Output

```html
<nav class="as-pagination" aria-label="Results pagination">
    <a href="?page=1" class="pagination-first">«</a>
    <a href="?page=2" class="pagination-prev">‹</a>
    <a href="?page=1">1</a>
    <a href="?page=2">2</a>
    <a href="?page=3" aria-current="page">3</a>
    <a href="?page=4">4</a>
    <a href="?page=5">5</a>
    <a href="?page=4" class="pagination-next">›</a>
    <a href="?page=10" class="pagination-last">»</a>
</nav>
```

## Styling

Pagination styling is provided by `pagination.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--pagination-gap` | Gap between items |
| `--pagination-btn-size` | Button dimensions |
| `--pagination-bg` | Button background |
| `--pagination-border` | Button border |
| `--pagination-active-bg` | Current page background |
| `--pagination-active-color` | Current page text |

### Special Classes

| Class | Purpose |
|-------|---------|
| `pagination-first` | First page button |
| `pagination-prev` | Previous page button |
| `pagination-next` | Next page button |
| `pagination-last` | Last page button |
| `pagination-ellipsis` | Ellipsis (…) indicator |

## Examples

### Basic Pagination

```html
{( cn:preset.ui.pagination content="
    <a href='?page=1'>1</a>
    <a href='?page=2'>2</a>
    <a href='?page=3' aria-current='page'>3</a>
    <a href='?page=4'>4</a>
    <a href='?page=5'>5</a>
" )}
```

### With Ellipsis

```html
{( cn:preset.ui.pagination content="
    <a href='?page=1' class='pagination-prev'>‹</a>
    <a href='?page=1'>1</a>
    <span class='pagination-ellipsis'>…</span>
    <a href='?page=49'>49</a>
    <a href='?page=50' aria-current='page'>50</a>
    <a href='?page=51'>51</a>
    <span class='pagination-ellipsis'>…</span>
    <a href='?page=100'>100</a>
    <a href='?page=51' class='pagination-next'>›</a>
" )}
```

### Disabled Navigation

```html
<a href='#' aria-disabled='true' class='pagination-prev'>‹</a>
```

## Accessibility

- Uses `<nav>` with `aria-label`
- Current page marked with `aria-current="page"`
- Disabled links use `aria-disabled="true"`

## See Also

- [cn:preset.layout.breadcrumb](../layout/breadcrumb.md) — Breadcrumb navigation
- [cn:preset.layout.nav](../layout/nav.md) — Navigation menu

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
