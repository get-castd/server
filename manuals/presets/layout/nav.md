# cn:preset.layout.nav

Navigation menu container.

## Usage

```html
{( cn:preset.layout.nav 
    label="Main navigation" 
    content="<a href='/'>Home</a><a href='/about'>About</a><a href='/contact'>Contact</a>" 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Navigation links (supports HTML) |
| `label` | string | — | Accessible label (`aria-label`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<nav aria-label="Main navigation">
    <a href="/">Home</a>
    <a href="/about">About</a>
    <a href="/contact">Contact</a>
</nav>
```

## Styling

Navigation styling is provided by `castd.css`. Links are displayed inline with consistent spacing.

## Examples

### Main Navigation

```html
{( cn:preset.layout.nav 
    label="Main" 
    content="
        <a href='/'>Home</a>
        <a href='/products'>Products</a>
        <a href='/services'>Services</a>
        <a href='/about'>About</a>
    " 
)}
```

### With Dropdown

```html
{( cn:preset.layout.nav 
    label="Main" 
    content="
        <a href='/'>Home</a>
        {( cn:preset.ui.dropdown trigger='Products' content='
            <li><a href=\"/widgets\">Widgets</a></li>
            <li><a href=\"/gadgets\">Gadgets</a></li>
        ' )}
        <a href='/about'>About</a>
    " 
)}
```

### Active State

Mark the current page link:

```html
{( cn:preset.layout.nav content="
    <a href='/' aria-current='page'>Home</a>
    <a href='/about'>About</a>
" )}
```

### Vertical Navigation

```html
{( cn:preset.layout.nav 
    style="display: flex; flex-direction: column;" 
    content="
        <a href='/dashboard'>Dashboard</a>
        <a href='/profile'>Profile</a>
        <a href='/settings'>Settings</a>
    " 
)}
```

## Accessibility

- Always provide `aria-label` when multiple `<nav>` elements exist
- Use `aria-current="page"` on the current page link
- Ensure keyboard navigation works (native with `<a>` elements)

## See Also

- [cn:preset.layout.header](header.md) — Site header
- [cn:preset.layout.sidebar](sidebar.md) — Side navigation
- [cn:preset.layout.breadcrumb](breadcrumb.md) — Breadcrumb navigation

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
