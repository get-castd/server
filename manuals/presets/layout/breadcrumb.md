# cn:preset.layout.breadcrumb

Breadcrumb navigation trail.

## Usage

```html
{( cn:preset.layout.breadcrumb content="
    <li><a href='/'>Home</a></li>
    <li><a href='/products'>Products</a></li>
    <li aria-current='page'>Widget Pro</li>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | `<li>` elements with links |
| `label` | string | `"Breadcrumb"` | Accessible label |
| `pills` | boolean | — | Pill-style variant (`like-pills`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<nav class="as-breadcrumb" aria-label="Breadcrumb">
    <ol>
        <li><a href="/">Home</a></li>
        <li><a href="/products">Products</a></li>
        <li aria-current="page">Widget Pro</li>
    </ol>
</nav>
```

## Styling

Breadcrumb styling is provided by `castd.css`. Separators are added via CSS `::before` pseudo-elements.

### Variants

| Class | Effect |
|-------|--------|
| `like-pills` | Pill/button style breadcrumbs |

## Examples

### Basic Breadcrumb

```html
{( cn:preset.layout.breadcrumb content="
    <li><a href='/'>Home</a></li>
    <li><a href='/docs'>Documentation</a></li>
    <li aria-current='page'>Getting Started</li>
" )}
```

### Pill Style

```html
{( cn:preset.layout.breadcrumb pills=true content="
    <li><a href='/'>Home</a></li>
    <li><a href='/category'>Category</a></li>
    <li aria-current='page'>Item</li>
" )}
```

### With Icons

```html
{( cn:preset.layout.breadcrumb content="
    <li><a href='/'>🏠 Home</a></li>
    <li><a href='/settings'>⚙️ Settings</a></li>
    <li aria-current='page'>🔒 Security</li>
" )}
```

### E-commerce Path

```html
{( cn:preset.layout.breadcrumb content="
    <li><a href='/'>Shop</a></li>
    <li><a href='/electronics'>Electronics</a></li>
    <li><a href='/electronics/phones'>Phones</a></li>
    <li aria-current='page'>iPhone 15 Pro</li>
" )}
```

## Accessibility

- Uses semantic `<nav>` with `aria-label`
- Uses ordered list `<ol>` for structure
- Current page marked with `aria-current="page"`
- Screen readers announce the navigation trail

## Schema.org Markup

For SEO, add structured data:

```html
<nav class="as-breadcrumb" aria-label="Breadcrumb">
    <ol itemscope itemtype="https://schema.org/BreadcrumbList">
        <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a href="/" itemprop="item"><span itemprop="name">Home</span></a>
            <meta itemprop="position" content="1">
        </li>
        <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name" aria-current="page">Current</span>
            <meta itemprop="position" content="2">
        </li>
    </ol>
</nav>
```

## See Also

- [cn:preset.layout.nav](nav.md) — Navigation menu
- [cn:preset.layout.header](header.md) — Site header

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
