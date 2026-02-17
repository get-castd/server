# cn:preset.layout.header

Site header with optional logo.

## Usage

```html
{( cn:preset.layout.header 
    logo="<img src='/logo.svg' alt='Site'>" 
    content="{( cn:preset.layout.nav content='<a href=\"/\">Home</a><a href=\"/about\">About</a>' )}" 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Header content (supports HTML) |
| `id` | string | — | Element ID |
| `logo` | string | — | Logo HTML (image or text) |
| `logo_href` | string | `"/"` | Logo link URL |
| `style` | string | — | Inline CSS styles |

## Output

```html
<header>
    <a href="/"><img src="/logo.svg" alt="Site"></a>
    <nav>
        <a href="/">Home</a>
        <a href="/about">About</a>
    </nav>
</header>
```

## Styling

Header styling is provided by `castd.css`. The header uses flexbox with space-between alignment.

## Examples

### Simple Header

```html
{( cn:preset.layout.header 
    logo="<strong>MySite</strong>" 
    content="<a href='/login'>Login</a>" 
)}
```

### Header with Navigation

```html
{( cn:preset.layout.header 
    logo="<img src='/logo.svg' alt='Brand' width='120'>" 
    content="
        {( cn:preset.layout.nav content='
            <a href=\"/\">Home</a>
            <a href=\"/products\">Products</a>
            <a href=\"/about\">About</a>
            <a href=\"/contact\">Contact</a>
        ' )}
        {( cn:preset.form.button label='Get Started' )}
    " 
)}
```

### Header with Search

```html
{( cn:preset.layout.header 
    logo="<strong>Docs</strong>" 
    content="
        {( cn:preset.layout.nav content='<a href=\"/guide\">Guide</a><a href=\"/api\">API</a>' )}
        {( cn:preset.form.search name='q' placeholder='Search docs...' )}
    " 
)}
```

### Sticky Header

```html
{( cn:preset.layout.header 
    style="position: sticky; top: 0; z-index: 100;" 
    logo="<strong>App</strong>" 
    content="{( cn:preset.layout.nav content='...' )}" 
)}
```

## See Also

- [cn:preset.layout.nav](nav.md) — Navigation menu
- [cn:preset.layout.footer](footer.md) — Site footer

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
