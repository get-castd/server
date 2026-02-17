# cn:preset.layout.container

Content width constraint wrapper.

## Usage

```html
{( cn:preset.layout.container content="<p>Centred content with max-width</p>" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Container content (supports HTML) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-container">
    <p>Centred content with max-width</p>
</div>
```

## Styling

Container styling is provided by `castd.css`.

### CSS Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `--container-width` | `1200px` | Maximum width |
| `--container-padding` | `1rem` | Horizontal padding |

## Examples

### Basic Container

```html
{( cn:preset.layout.container content="
    <h1>Page Title</h1>
    <p>This content is constrained to a readable width.</p>
" )}
```

### Narrow Container

```html
{( cn:preset.layout.container 
    style="--container-width: 800px;" 
    content="<article>Narrow article content...</article>" 
)}
```

### Wide Container

```html
{( cn:preset.layout.container 
    style="--container-width: 1400px;" 
    content="<div class='dashboard'>Wide dashboard content...</div>" 
)}
```

### Full Page Layout

```html
{( cn:preset.layout.header logo="Logo" content="..." )}

{( cn:preset.layout.container content="
    <main>
        <h1>Welcome</h1>
        <p>Main page content goes here.</p>
    </main>
" )}

{( cn:preset.layout.footer content="© 2025" )}
```

### Nested Containers

Avoid nesting containers. If you need different widths:

```html
<!-- Hero: full width -->
<section class="hero">
    <h1>Hero Title</h1>
</section>

<!-- Content: constrained -->
{( cn:preset.layout.container content="
    <article>Main content</article>
" )}
```

## See Also

- [cn:preset.layout.grid](grid.md) — Grid layout

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
