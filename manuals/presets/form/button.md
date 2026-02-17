# cn:preset.form.button

Multifunctional button with optional action handlers, loading states, and modal triggers.

---

## Usage

```html
{( cn:preset.form.button label="Submit" )}

{( cn:preset.form.button label="Save" variant="is-secondary" )}

{( cn:preset.form.button label="Delete" action="/api/delete" method="DELETE" )}
```

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | **Required.** Button text |
| `type` | string | `"button"` | Button type: `button`, `submit`, `reset` |
| `variant` | string | — | CSS class: `is-secondary` |
| `disabled` | boolean | — | Disabled state |
| `action` | string | — | Action URL for `data-cn-action` |
| `method` | string | `"POST"` | HTTP method when action is set |
| `loading` | string | — | Loading indicator selector |
| `loading-class` | string | — | Class to apply during loading |
| `data` | string | — | Form data selector |
| `open` | string | — | Dialog ID to open on click |
| `close` | boolean | — | Close parent dialog on click |

---

## Examples

### Basic Button

```html
{( cn:preset.form.button label="Click me" )}
```

Output:
```html
<button type="button">Click me</button>
```

### Submit Button

```html
{( cn:preset.form.button label="Submit" type="submit" )}
```

### Secondary Style

```html
{( cn:preset.form.button label="Cancel" variant="is-secondary" )}
```

### Disabled Button

```html
{( cn:preset.form.button label="Not available" disabled=true )}
```

### Action Button

```html
{( cn:preset.form.button 
    label="Save" 
    action="/api/save" 
    method="POST" 
    data="#form" 
)}
```

Output:
```html
<button type="button" 
    data-cn-action="/api/save" 
    data-cn-method="POST" 
    data-cn-data="#form">Save</button>
```

### Modal Trigger

```html
{( cn:preset.form.button label="Open Settings" open="settings-dialog" )}
```

### Modal Close

```html
{( cn:preset.form.button label="Close" close=true variant="is-secondary" )}
```

---

## Styling

Button styling is provided by `castd.css`. No additional CSS in the preset.

### CSS Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `--button-weight` | 500 | Font weight |
| `--button-radius` | 12px | Border radius |
| `--button-background` | `var(--accent)` | Primary background |
| `--button-color` | `var(--text-inv)` | Primary text |
| `--button-secondary-background` | `var(--control)` | Secondary background |
| `--button-secondary-color` | `var(--text)` | Secondary text |

### Inline Override

```html
{( cn:preset.form.button 
    label="Custom" 
    style="--button-radius: 0; --button-background: oklch(60% 0.2 180);" 
)}
```

---

## Accessibility

- Uses native `<button>` element
- Supports `disabled` attribute
- Keyboard accessible by default
- Focus state styled by framework

---

*Copyright 2025 Vivian Voss. Apache-2.0*
