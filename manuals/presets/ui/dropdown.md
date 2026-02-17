# cn:preset.ui.dropdown

Dropdown menu using native `<details>` element.

## Usage

```html
{( cn:preset.ui.dropdown 
    trigger="Menu" 
    content="<li><a href='/profile'>Profile</a></li><li><a href='/settings'>Settings</a></li><li><a href='/logout'>Logout</a></li>" 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `trigger` | string | **Required** | Button/trigger text |
| `content` | string | **Required** | Menu items (HTML `<li>` elements) |
| `anchor` | string | — | CSS anchor position (e.g. `--anchor-bottom`) |

## Output

```html
<details class="as-dropdown-trigger">
    <summary>Menu</summary>
    <ul class="as-dropdown">
        <li><a href="/profile">Profile</a></li>
        <li><a href="/settings">Settings</a></li>
        <li><a href="/logout">Logout</a></li>
    </ul>
</details>
```

## Styling

Dropdown styling is provided by `castd.css`. The dropdown is positioned absolutely relative to the trigger.

### Positioning

Use the `anchor` parameter to control position:

| Value | Position |
|-------|----------|
| `--anchor-bottom` | Below trigger (default) |
| `--anchor-top` | Above trigger |
| `--anchor-left` | Left-aligned |
| `--anchor-right` | Right-aligned |

## Examples

### Basic Dropdown

```html
{( cn:preset.ui.dropdown 
    trigger="Options" 
    content="<li><button>Edit</button></li><li><button>Duplicate</button></li><li><button>Delete</button></li>" 
)}
```

### Navigation Dropdown

```html
<nav>
    <a href="/">Home</a>
    {( cn:preset.ui.dropdown 
        trigger="Products" 
        content="<li><a href='/widgets'>Widgets</a></li><li><a href='/gadgets'>Gadgets</a></li><li><a href='/tools'>Tools</a></li>" 
    )}
    <a href="/about">About</a>
</nav>
```

### User Menu

```html
{( cn:preset.ui.dropdown 
    trigger="<img src='/avatar.jpg' alt='User'> John" 
    anchor="--anchor-right" 
    content="<li><a href='/profile'>My Profile</a></li><li><a href='/settings'>Settings</a></li><li><hr></li><li><a href='/logout'>Sign out</a></li>" 
)}
```

### With Icons

```html
{( cn:preset.ui.dropdown 
    trigger="Actions" 
    content="<li><button>✏️ Edit</button></li><li><button>📋 Copy</button></li><li><button>🗑️ Delete</button></li>" 
)}
```

## JavaScript Enhancement

### Close on Selection

```javascript
document.querySelectorAll('.as-dropdown a, .as-dropdown button').forEach(item => {
    item.addEventListener('click', () => {
        item.closest('details').removeAttribute('open');
    });
});
```

### Close on Outside Click

```javascript
document.addEventListener('click', (e) => {
    document.querySelectorAll('details.as-dropdown-trigger[open]').forEach(dropdown => {
        if (!dropdown.contains(e.target)) {
            dropdown.removeAttribute('open');
        }
    });
});
```

## Accessibility

- Uses native `<details>/<summary>` for built-in keyboard support
- Enter/Space toggles dropdown
- Escape closes dropdown (with JavaScript enhancement)

## See Also

- [cn:preset.form.select](../form/select.md) — Form select dropdown
- [cn:preset.ui.accordion](accordion.md) — Expandable sections

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
