# cn:preset.form.checkbox

Checkbox input rendered as a toggle switch.

## Usage

```html
{( cn:preset.form.checkbox label="Enable notifications" name="notifications" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | **Required** | Checkbox label text |
| `id` | string | — | Element ID |
| `name` | string | — | Form field name |
| `value` | string | — | Value when checked |
| `checked` | boolean | — | Initially checked |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable checkbox |

## Output

```html
<label>
    <input type="checkbox" name="notifications">
    Enable notifications
</label>
```

## Styling

Checkbox is styled as a toggle switch by `castd.css`. The native checkbox is visually hidden and replaced with a custom track/thumb design.

### States

- `:checked` — Thumb slides right, track changes colour
- `:focus` — Focus ring on track
- `:disabled` — Reduced opacity

## Examples

### Basic Toggle

```html
{( cn:preset.form.checkbox label="Dark mode" name="dark_mode" )}
```

### Pre-checked

```html
{( cn:preset.form.checkbox 
    label="Accept terms and conditions" 
    name="terms" 
    required=true 
    checked=true 
)}
```

### With Custom Value

```html
{( cn:preset.form.checkbox 
    label="Subscribe to newsletter" 
    name="subscribe" 
    value="yes" 
)}
```

## Traditional Checkboxes

For traditional checkbox styling with checkmarks (multiple options in a group), use a `<fieldset>` pattern:

```html
<fieldset>
    <legend>Select toppings</legend>
    {( cn:preset.form.checkbox label="Cheese" name="toppings" value="cheese" )}
    {( cn:preset.form.checkbox label="Pepperoni" name="toppings" value="pepperoni" )}
    {( cn:preset.form.checkbox label="Mushrooms" name="toppings" value="mushrooms" )}
</fieldset>
```

## See Also

- [cn:preset.form.radio](radio.md) — Radio buttons
- [cn:preset.form.select](select.md) — Dropdown selection

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
