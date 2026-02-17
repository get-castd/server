# cn:preset.ui.dialog

Modal dialog using native `<dialog>` element.

## Usage

```html
{( cn:preset.ui.dialog 
    id="confirm-dialog" 
    label="Confirm Action" 
    content="<p>Are you sure?</p><button onclick='this.closest(\"dialog\").close()'>Close</button>" 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Dialog content (supports HTML) |
| `id` | string | — | Element ID (required for opening/closing) |
| `label` | string | — | Dialog title (creates accessible heading) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<dialog id="confirm-dialog" aria-labelledby="confirm-dialog-title">
    <h3 id="confirm-dialog-title">Confirm Action</h3>
    <p>Are you sure?</p>
    <button onclick='this.closest("dialog").close()'>Close</button>
</dialog>
```

## Styling

Dialog styling is provided by `castd.css`. The backdrop is styled via `::backdrop`.

## JavaScript API

### Opening a Dialog

```javascript
// Modal (with backdrop)
document.getElementById('confirm-dialog').showModal();

// Non-modal (no backdrop)
document.getElementById('confirm-dialog').show();
```

### Closing a Dialog

```javascript
document.getElementById('confirm-dialog').close();

// Or with a return value
document.getElementById('confirm-dialog').close('confirmed');
```

### Detecting Close

```javascript
const dialog = document.getElementById('confirm-dialog');

dialog.addEventListener('close', () => {
    console.log('Dialog closed with:', dialog.returnValue);
});
```

## Examples

### Confirmation Dialog

```html
{( cn:preset.ui.dialog 
    id="delete-dialog" 
    label="Delete Item" 
    content="<p>This action cannot be undone.</p><form method='dialog'><button value='cancel'>Cancel</button><button value='confirm'>Delete</button></form>" 
)}

<button onclick="document.getElementById('delete-dialog').showModal()">
    Delete
</button>
```

### Form Dialog

```html
{( cn:preset.ui.dialog 
    id="edit-dialog" 
    label="Edit Profile" 
    content="<form method='dialog'>{( cn:preset.form.input label='Name' name='name' )}{( cn:preset.form.button label='Save' type='submit' )}</form>" 
)}
```

### Close on Backdrop Click

```javascript
const dialog = document.getElementById('my-dialog');

dialog.addEventListener('click', (e) => {
    if (e.target === dialog) {
        dialog.close();
    }
});
```

### Prevent Escape Key Close

```javascript
dialog.addEventListener('cancel', (e) => {
    e.preventDefault();
});
```

## Accessibility

- Always provide a `label` for the dialog title
- The `aria-labelledby` attribute is automatically set
- Focus is trapped within the modal when open
- Escape key closes the dialog by default

## See Also

- [cn:preset.ui.card](card.md) — Non-modal content container
- [cn:preset.ui.toast](toast.md) — Non-blocking notifications

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
