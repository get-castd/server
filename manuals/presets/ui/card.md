# cn:preset.ui.card

Container for grouped content with optional header and footer.

## Usage

```html
{( cn:preset.ui.card 
    header="Card Title" 
    content="<p>Card content goes here.</p>" 
    footer="<button>Action</button>" 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Main card content (supports HTML) |
| `header` | string | — | Header text |
| `footer` | string | — | Footer content (supports HTML) |
| `shadow` | boolean | — | Add drop shadow (`show-shadow`) |
| `hover` | boolean | — | Enable hover effect (`has-hover`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<article class="as-card show-shadow has-hover">
    <header>Card Title</header>
    <p>Card content goes here.</p>
    <footer><button>Action</button></footer>
</article>
```

## Styling

Card styling is provided by `castd.css`.

### Modifier Classes

| Class | Effect |
|-------|--------|
| `show-shadow` | Adds drop shadow |
| `has-hover` | Lifts on hover |

## Examples

### Basic Card

```html
{( cn:preset.ui.card 
    header="Welcome" 
    content="<p>Thanks for signing up!</p>" 
)}
```

### Card with Actions

```html
{( cn:preset.ui.card 
    header="Subscription" 
    content="<p>Your plan: <strong>Pro</strong></p><p>Next billing: 1 Feb 2025</p>" 
    footer="{( cn:preset.form.button label='Manage' variant='secondary' )} {( cn:preset.form.button label='Upgrade' )}" 
)}
```

### Interactive Card

```html
{( cn:preset.ui.card 
    shadow=true 
    hover=true 
    content="<h3>Project Alpha</h3><p>Last updated 2 hours ago</p>" 
)}
```

### Image Card

```html
{( cn:preset.ui.card 
    content="<img src='/img/hero.jpg' alt='Hero'><h3>Featured Article</h3><p>Lorem ipsum dolor sit amet...</p>" 
    footer="<a href='/article'>Read more</a>" 
    shadow=true 
)}
```

### Grid of Cards

```html
<div class="as-grid" style="--columns: 3;">
    {( cn:preset.ui.card header="Plan A" content="<p>Basic features</p>" footer="£9/mo" )}
    {( cn:preset.ui.card header="Plan B" content="<p>Pro features</p>" footer="£19/mo" shadow=true )}
    {( cn:preset.ui.card header="Plan C" content="<p>Enterprise</p>" footer="Contact us" )}
</div>
```

## See Also

- [cn:preset.layout.grid](../layout/grid.md) — Grid layout
- [cn:preset.ui.dialog](dialog.md) — Modal dialogues

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
