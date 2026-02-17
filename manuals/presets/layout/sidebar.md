# cn:preset.layout.sidebar

Side panel for navigation or supplementary content.

## Usage

```html
{( cn:preset.layout.sidebar 
    label="Documentation" 
    content="
        <h3>Getting Started</h3>
        <a href='/intro'>Introduction</a>
        <a href='/install'>Installation</a>
    " 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Sidebar content (supports HTML) |
| `id` | string | — | Element ID |
| `label` | string | — | Accessible label (`aria-label`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<aside aria-label="Documentation">
    <h3>Getting Started</h3>
    <a href="/intro">Introduction</a>
    <a href="/install">Installation</a>
</aside>
```

## Styling

Sidebar styling is provided by `castd.css`.

## Examples

### Documentation Sidebar

```html
{( cn:preset.layout.sidebar 
    label="Docs navigation" 
    content="
        <h4>Guide</h4>
        <a href='/guide/intro'>Introduction</a>
        <a href='/guide/setup'>Setup</a>
        <a href='/guide/usage'>Usage</a>
        
        <h4>Reference</h4>
        <a href='/ref/api'>API</a>
        <a href='/ref/config'>Configuration</a>
    " 
)}
```

### Dashboard Sidebar

```html
{( cn:preset.layout.sidebar 
    id="main-sidebar" 
    content="
        <nav>
            <a href='/dashboard'>📊 Dashboard</a>
            <a href='/projects'>📁 Projects</a>
            <a href='/team'>👥 Team</a>
            <a href='/settings'>⚙️ Settings</a>
        </nav>
    " 
)}
```

### Sidebar with Sections

```html
{( cn:preset.layout.sidebar content="
    <details open>
        <summary>Components</summary>
        <a href='/components/button'>Button</a>
        <a href='/components/input'>Input</a>
        <a href='/components/card'>Card</a>
    </details>
    <details>
        <summary>Utilities</summary>
        <a href='/utilities/spacing'>Spacing</a>
        <a href='/utilities/colours'>Colours</a>
    </details>
" )}
```

## Layout Integration

Sidebar with main content:

```html
<div style="display: grid; grid-template-columns: 250px 1fr;">
    {( cn:preset.layout.sidebar label="Navigation" content="..." )}
    <main>
        <!-- Main content -->
    </main>
</div>
```

## Collapsible Sidebar

```javascript
const sidebar = document.getElementById('main-sidebar');
const toggle = document.getElementById('sidebar-toggle');

toggle.addEventListener('click', () => {
    sidebar.classList.toggle('is-collapsed');
});
```

## See Also

- [cn:preset.layout.nav](nav.md) — Navigation menu
- [cn:preset.layout.header](header.md) — Site header

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
