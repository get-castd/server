# cn:preset.layout.footer

Site footer.

## Usage

```html
{( cn:preset.layout.footer content="<p>© 2025 Company Name</p>" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Footer content (supports HTML) |
| `id` | string | — | Element ID |
| `style` | string | — | Inline CSS styles |

## Output

```html
<footer>
    <p>© 2025 Company Name</p>
</footer>
```

## Styling

Footer styling is provided by `castd.css`.

## Examples

### Simple Footer

```html
{( cn:preset.layout.footer content="
    <p>© 2025 MyCompany. All rights reserved.</p>
" )}
```

### Footer with Links

```html
{( cn:preset.layout.footer content="
    <nav>
        <a href='/privacy'>Privacy Policy</a>
        <a href='/terms'>Terms of Service</a>
        <a href='/contact'>Contact</a>
    </nav>
    <p>© 2025 MyCompany</p>
" )}
```

### Multi-column Footer

```html
{( cn:preset.layout.footer content="
    {( cn:preset.layout.grid columns='4' content='
        <div>
            <h4>Product</h4>
            <a href=\"/features\">Features</a>
            <a href=\"/pricing\">Pricing</a>
            <a href=\"/docs\">Documentation</a>
        </div>
        <div>
            <h4>Company</h4>
            <a href=\"/about\">About</a>
            <a href=\"/blog\">Blog</a>
            <a href=\"/careers\">Careers</a>
        </div>
        <div>
            <h4>Support</h4>
            <a href=\"/help\">Help Centre</a>
            <a href=\"/contact\">Contact</a>
            <a href=\"/status\">Status</a>
        </div>
        <div>
            <h4>Legal</h4>
            <a href=\"/privacy\">Privacy</a>
            <a href=\"/terms\">Terms</a>
            <a href=\"/cookies\">Cookies</a>
        </div>
    ' )}
    <hr>
    <p>© 2025 MyCompany. All rights reserved.</p>
" )}
```

### Footer with Social Links

```html
{( cn:preset.layout.footer content="
    <div>
        <a href='https://twitter.com/company'>Twitter</a>
        <a href='https://github.com/company'>GitHub</a>
        <a href='https://linkedin.com/company/company'>LinkedIn</a>
    </div>
    <p>Made with ♥ in London</p>
" )}
```

## See Also

- [cn:preset.layout.header](header.md) — Site header
- [cn:preset.layout.grid](grid.md) — Grid layout

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
