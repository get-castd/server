# cn:preset.ui.avatar

User avatar display with image or initials fallback.

## Usage

```html
{( cn:preset.ui.avatar src="/avatars/user.jpg" alt="John Doe" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `src` | string | — | Image URL |
| `alt` | string | **Required** | Alt text / user name |
| `initials` | string | — | Fallback initials (displayed when no image) |
| `size` | string | `"md"` | Size: `xs`, `sm`, `md`, `lg`, `xl` |
| `shape` | string | `"circle"` | Shape: `circle`, `square` |
| `status` | string | — | Status indicator: `online`, `offline`, `busy`, `away` |
| `style` | string | — | Inline CSS styles |

## Output

```html
<span class="as-avatar like-md" data-initials="JD">
    <img src="/avatars/user.jpg" alt="John Doe">
</span>
```

## Styling

Avatar styling is provided by `avatar.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--avatar-size` | Avatar dimensions |
| `--avatar-bg` | Initials background |
| `--avatar-color` | Initials text colour |

### Sizes

| Class | Size |
|-------|------|
| `like-xs` | 1.5rem |
| `like-sm` | 2rem |
| `like-md` | 2.5rem |
| `like-lg` | 3.5rem |
| `like-xl` | 5rem |

## Examples

### Basic Avatar

```html
{( cn:preset.ui.avatar src="/user.jpg" alt="Jane Smith" )}
```

### Initials Fallback

```html
{( cn:preset.ui.avatar alt="Jane Smith" initials="JS" )}
```

### Sizes

```html
{( cn:preset.ui.avatar alt="User" initials="U" size="xs" )}
{( cn:preset.ui.avatar alt="User" initials="U" size="sm" )}
{( cn:preset.ui.avatar alt="User" initials="U" size="md" )}
{( cn:preset.ui.avatar alt="User" initials="U" size="lg" )}
{( cn:preset.ui.avatar alt="User" initials="U" size="xl" )}
```

### With Status

```html
{( cn:preset.ui.avatar src="/user.jpg" alt="User" status="online" )}
{( cn:preset.ui.avatar src="/user.jpg" alt="User" status="busy" )}
{( cn:preset.ui.avatar src="/user.jpg" alt="User" status="away" )}
{( cn:preset.ui.avatar src="/user.jpg" alt="User" status="offline" )}
```

### Square Avatar

```html
{( cn:preset.ui.avatar src="/user.jpg" alt="User" shape="square" )}
```

### Avatar Group

```html
<div class="as-avatar-group">
    {( cn:preset.ui.avatar src="/user1.jpg" alt="User 1" )}
    {( cn:preset.ui.avatar src="/user2.jpg" alt="User 2" )}
    {( cn:preset.ui.avatar src="/user3.jpg" alt="User 3" )}
    {( cn:preset.ui.avatar alt="+5" initials="+5" )}
</div>
```

## See Also

- [cn:preset.ui.badge](badge.md) — Status badges
- [cn:preset.ui.chip](chip.md) — Interactive chips

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
