# cn:preset.form.input

Text input field with optional label and validation support.

## Usage

```html
{( cn:preset.form.input label="Email" type="email" placeholder="you@example.com" required=true )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text (rendered as `<label>`) |
| `id` | string | — | Element ID (links label to input) |
| `name` | string | — | Form field name |
| `type` | string | `"text"` | Input type: `text`, `email`, `tel`, `url`, `number`, `date`, etc. |
| `placeholder` | string | — | Placeholder text |
| `value` | string | — | Initial value |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable input |
| `readonly` | boolean | — | Read-only mode |
| `minlength` | number | — | Minimum character length |
| `maxlength` | number | — | Maximum character length |
| `pattern` | string | — | Regex validation pattern |
| `autocomplete` | string | — | Autocomplete hint (e.g. `email`, `tel`) |
| `validate` | string | — | Custom validation rule (sets `data-cn-validate`) |

## Output

```html
<label for="email">Email</label>
<input type="email" id="email" name="email" placeholder="you@example.com" required>
```

## Styling

Input styling is provided by `castd.css`. No additional CSS required.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity
- `:invalid` — Error styling (after interaction)
- `:valid` — Success styling (when validated)

## Examples

### Basic Text Input

```html
{( cn:preset.form.input label="Name" name="name" )}
```

### Email with Validation

```html
{( cn:preset.form.input 
    label="Email Address" 
    type="email" 
    name="email" 
    required=true 
    autocomplete="email" 
)}
```

### Number Input with Range

```html
{( cn:preset.form.input 
    label="Quantity" 
    type="number" 
    name="qty" 
    value="1" 
    min="1" 
    max="100" 
)}
```

### Pattern Validation

```html
{( cn:preset.form.input 
    label="Postcode" 
    name="postcode" 
    pattern="[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}" 
    placeholder="SW1A 1AA" 
)}
```

## See Also

- [cn:preset.form.password](password.md) — Password input
- [cn:preset.form.search](search.md) — Search input
- [cn:preset.form.textarea](textarea.md) — Multi-line text

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
