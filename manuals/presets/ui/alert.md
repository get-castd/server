# cn:preset.ui.alert

Alert notification for displaying messages, warnings, or status information.

## Usage

```html
{( cn:preset.ui.alert state="success" content="Your changes have been saved." )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Alert message (supports HTML) |
| `state` | string | — | Visual state: `info`, `success`, `warning`, `error` |
| `role` | string | — | ARIA role (e.g. `alert`, `status`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<aside class="as-alert is-success">
    Your changes have been saved.
</aside>
```

## Styling

Alert styling is provided by `castd.css`.

### State Classes

| Class | Use Case | Colour |
|-------|----------|--------|
| `is-info` | Informational messages | Blue |
| `is-success` | Success confirmations | Green |
| `is-warning` | Warnings | Amber |
| `is-error` | Errors | Red |

## Examples

### Information Alert

```html
{( cn:preset.ui.alert 
    state="info" 
    content="New features are available. <a href='/changelog'>View changelog</a>" 
)}
```

### Success Message

```html
{( cn:preset.ui.alert 
    state="success" 
    content="Account created successfully." 
    role="status" 
)}
```

### Warning

```html
{( cn:preset.ui.alert 
    state="warning" 
    content="Your session will expire in 5 minutes." 
)}
```

### Error

```html
{( cn:preset.ui.alert 
    state="error" 
    content="Failed to save changes. Please try again." 
    role="alert" 
)}
```

### With Rich Content

```html
{( cn:preset.ui.alert 
    state="info" 
    content="<strong>Note:</strong> This action cannot be undone. Please review your changes carefully before proceeding." 
)}
```

## Accessibility

- Use `role="alert"` for important, time-sensitive messages
- Use `role="status"` for non-urgent status updates
- Ensure sufficient colour contrast for all states

## See Also

- [cn:preset.ui.toast](toast.md) — Temporary notifications

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
