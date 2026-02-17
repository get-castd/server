# cn:preset.form.textarea

Multi-line text input area.

## Usage

```html
{( cn:preset.form.textarea label="Message" name="message" placeholder="Enter your message..." rows="4" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text |
| `id` | string | — | Element ID (links label to textarea) |
| `name` | string | — | Form field name |
| `placeholder` | string | — | Placeholder text |
| `value` | string | — | Initial content |
| `rows` | number | — | Visible rows (height) |
| `cols` | number | — | Visible columns (width) |
| `minlength` | number | — | Minimum character length |
| `maxlength` | number | — | Maximum character length |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable textarea |
| `readonly` | boolean | — | Read-only mode |

## Output

```html
<label for="message">Message</label>
<textarea id="message" name="message" placeholder="Enter your message..." rows="4"></textarea>
```

## Styling

Textarea styling is provided by `castd.css`.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity
- `:invalid` — Error styling
- `:valid` — Success styling

### Resize Behaviour

By default, textareas can be resized vertically. To control:

```css
textarea { resize: vertical; }   /* Default */
textarea { resize: none; }       /* Disable */
textarea { resize: both; }       /* Both directions */
```

## Examples

### Basic Textarea

```html
{( cn:preset.form.textarea label="Bio" name="bio" rows="3" )}
```

### With Character Limit

```html
{( cn:preset.form.textarea 
    label="Description" 
    name="description" 
    maxlength="500" 
    placeholder="Max 500 characters" 
)}
```

### Required with Validation

```html
{( cn:preset.form.textarea 
    label="Feedback" 
    name="feedback" 
    required=true 
    minlength="20" 
    placeholder="Please provide at least 20 characters" 
)}
```

### Pre-filled Content

```html
{( cn:preset.form.textarea 
    label="Notes" 
    name="notes" 
    value="Default content here..." 
    rows="5" 
)}
```

## Character Counter

To add a live character counter:

```javascript
const textarea = document.querySelector('textarea[name="description"]');
const counter = document.querySelector('#char-count');
const max = textarea.maxLength;

textarea.addEventListener('input', () => {
    counter.textContent = `${textarea.value.length}/${max}`;
});
```

## See Also

- [cn:preset.form.input](input.md) — Single-line input

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
