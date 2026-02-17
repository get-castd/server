# cn:preset.ui.toast

Temporary notification message.

## Usage

```html
{( cn:preset.ui.toast message="Settings saved" state="success" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | string | **Required** | Toast message text |
| `state` | string | — | Visual state: `info`, `success`, `warning`, `error` |
| `leaving` | boolean | — | Add exit animation class (`is-leaving`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-toast is-success">Settings saved</div>
```

## Styling

Toast styling is provided by `castd.css`. Toasts are typically positioned fixed at the bottom or top of the viewport.

### State Classes

| Class | Use Case |
|-------|----------|
| `is-info` | Informational |
| `is-success` | Success confirmation |
| `is-warning` | Warning |
| `is-error` | Error |

### Animation Classes

| Class | Effect |
|-------|--------|
| `is-leaving` | Exit animation |

## Examples

### Success Toast

```html
{( cn:preset.ui.toast message="Profile updated" state="success" )}
```

### Error Toast

```html
{( cn:preset.ui.toast message="Failed to save" state="error" )}
```

### Warning Toast

```html
{( cn:preset.ui.toast message="Connection unstable" state="warning" )}
```

## JavaScript Toast System

Toasts are typically created dynamically:

```javascript
function showToast(message, state = 'info', duration = 3000) {
    const container = document.getElementById('toast-container') 
        || createToastContainer();
    
    const toast = document.createElement('div');
    toast.className = `as-toast is-${state}`;
    toast.textContent = message;
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('is-leaving');
        toast.addEventListener('animationend', () => toast.remove());
    }, duration);
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toast-container';
    container.style.cssText = 'position:fixed;bottom:1rem;right:1rem;display:flex;flex-direction:column;gap:0.5rem;z-index:1000';
    document.body.appendChild(container);
    return container;
}
```

### Usage

```javascript
showToast('Welcome back!', 'success');
showToast('Network error', 'error', 5000);
showToast('New message received', 'info');
```

## Toast Container CSS

```css
#toast-container {
    position: fixed;
    bottom: 1rem;
    right: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    z-index: 1000;
}
```

## Accessibility

- Toasts should use `role="status"` for non-critical messages
- Use `role="alert"` for important messages
- Ensure sufficient display duration for reading
- Provide a way to dismiss or pause auto-dismiss

## See Also

- [cn:preset.ui.alert](alert.md) — Persistent alert messages

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
