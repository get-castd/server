# cn:preset.ui.skeleton

Loading placeholder skeleton.

## Usage

```html
{( cn:preset.ui.skeleton type="text" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | string | — | Skeleton type: `text`, `circle`, `rect`, `card` |
| `width` | string | — | Custom width |
| `height` | string | — | Custom height |
| `animate` | boolean | `true` | Enable shimmer animation |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-skeleton like-text is-animated" aria-hidden="true">
    <span></span>
    <span></span>
    <span></span>
</div>
```

## Styling

Skeleton styling is provided by `skeleton.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--skeleton-bg` | Base colour |
| `--skeleton-highlight` | Shimmer highlight |
| `--skeleton-radius` | Border radius |

### Type Variants

| Type | Description |
|------|-------------|
| `like-text` | Multiple text lines |
| `like-circle` | Circular (avatars) |
| `like-rect` | Rectangle (images) |
| `like-card` | Card shape with image and text areas |

## Examples

### Text Skeleton

```html
{( cn:preset.ui.skeleton type="text" )}
```

### Avatar Skeleton

```html
{( cn:preset.ui.skeleton type="circle" width="48px" height="48px" )}
```

### Image Skeleton

```html
{( cn:preset.ui.skeleton type="rect" width="100%" height="200px" )}
```

### Card Skeleton

```html
{( cn:preset.ui.skeleton type="card" )}
```

### User List Skeleton

```html
<div class="user-list-skeleton">
    <div style="display: flex; gap: 1rem; align-items: center;">
        {( cn:preset.ui.skeleton type="circle" width="40px" height="40px" )}
        <div>
            {( cn:preset.ui.skeleton type="rect" width="150px" height="1em" )}
            {( cn:preset.ui.skeleton type="rect" width="100px" height="1em" )}
        </div>
    </div>
</div>
```

### Without Animation

```html
{( cn:preset.ui.skeleton type="text" animate=false )}
```

## Usage Pattern

Replace skeleton with content when loaded:

```javascript
async function loadContent() {
    const skeleton = document.querySelector('.as-skeleton');
    const content = await fetch('/api/content').then(r => r.text());
    
    skeleton.outerHTML = content;
}
```

## Accessibility

- Skeletons use `aria-hidden="true"` as they're decorative
- Use `aria-busy="true"` on the container while loading
- Announce loading state to screen readers

```html
<div aria-busy="true" aria-live="polite">
    {( cn:preset.ui.skeleton type="card" )}
</div>
```

## See Also

- [cn:preset.ui.card](card.md) — Content card

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
