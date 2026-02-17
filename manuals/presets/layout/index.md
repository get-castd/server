# Layout Presets

Page structure and layout components.

---

## Available Presets

| Preset | Description |
|--------|-------------|
| [header](header.md) | Site header with logo |
| [nav](nav.md) | Navigation menu |
| [sidebar](sidebar.md) | Side panel |
| [footer](footer.md) | Site footer |
| [container](container.md) | Width constraint wrapper |
| [grid](grid.md) | CSS grid layout |
| [breadcrumb](breadcrumb.md) | Breadcrumb navigation |

---

## Usage

```html
{( cn:preset.layout.{component} content="..." )}
```

---

## Page Structure

Typical page layout:

```html
{( cn:preset.layout.header 
    logo="<img src='/logo.svg' alt='Site'>" 
    content="{( cn:preset.layout.nav content='<a href=\"/\">Home</a>' )}" 
)}

{( cn:preset.layout.container content="
    {( cn:preset.layout.breadcrumb content='
        <li><a href=\"/\">Home</a></li>
        <li aria-current=\"page\">Current Page</li>
    ' )}
    
    <main>
        <h1>Page Title</h1>
        <p>Content here.</p>
    </main>
" )}

{( cn:preset.layout.footer content="<p>© 2025 Company</p>" )}
```

---

## Sidebar Layout

Two-column layout with sidebar:

```html
<div style="display: grid; grid-template-columns: 250px 1fr; min-height: 100vh;">
    {( cn:preset.layout.sidebar content="
        <nav>
            <a href='/dashboard'>Dashboard</a>
            <a href='/settings'>Settings</a>
        </nav>
    " )}
    
    <main>
        {( cn:preset.layout.container content="
            <h1>Dashboard</h1>
            <p>Main content</p>
        " )}
    </main>
</div>
```

---

## Grid Layouts

Responsive card grid:

```html
{( cn:preset.layout.grid columns="3" gap="1.5rem" content="
    {( cn:preset.ui.card header='Item 1' content='...' )}
    {( cn:preset.ui.card header='Item 2' content='...' )}
    {( cn:preset.ui.card header='Item 3' content='...' )}
" )}
```

---

## CSS Variables

Layout components use CSS variables for customisation:

| Variable | Default | Description |
|----------|---------|-------------|
| `--container-width` | 1200px | Maximum container width |
| `--container-padding` | 1rem | Container side padding |
| `--columns` | 1 | Grid column count |
| `--gap` | 1rem | Grid gap |

---

## Semantic HTML

Layout presets use semantic HTML elements:

| Preset | Element |
|--------|---------|
| header | `<header>` |
| nav | `<nav>` |
| sidebar | `<aside>` |
| footer | `<footer>` |
| breadcrumb | `<nav>` with `<ol>` |

---

## See Also

- [Form Presets](../form/index.md) — Form elements
- [UI Presets](../ui/index.md) — Display components

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
