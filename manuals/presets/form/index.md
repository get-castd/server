# Form Presets

Interactive form elements for user input.

---

## Available Presets

| Preset | Description |
|--------|-------------|
| [button](button.md) | Buttons and submit controls |
| [input](input.md) | Text input fields |
| [password](password.md) | Password input with visibility toggle |
| [search](search.md) | Search input |
| [textarea](textarea.md) | Multi-line text input |
| [checkbox](checkbox.md) | Checkbox (toggle switch style) |
| [radio](radio.md) | Radio buttons |
| [range](range.md) | Range slider |
| [select](select.md) | Dropdown select |
| [file](file.md) | File upload |
| [progress](progress.md) | Progress bar |
| [meter](meter.md) | Meter gauge |
| [segment](segment.md) | Segmented control |

---

## Usage

```html
{( cn:preset.form.{component} label="Label" name="field_name" )}
```

---

## Common Parameters

Most form presets share these parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `label` | string | Field label |
| `id` | string | Element ID |
| `name` | string | Form field name |
| `required` | boolean | Mark as required |
| `disabled` | boolean | Disable input |

---

## Example Form

```html
<form action="/submit" method="post">
    {( cn:preset.form.input label="Name" name="name" required=true )}
    {( cn:preset.form.input label="Email" type="email" name="email" required=true )}
    {( cn:preset.form.textarea label="Message" name="message" rows="4" )}
    {( cn:preset.form.checkbox label="Subscribe to newsletter" name="subscribe" )}
    {( cn:preset.form.button label="Send Message" type="submit" )}
</form>
```

---

## Validation

Form elements support HTML5 validation attributes:

| Attribute | Purpose |
|-----------|---------|
| `required` | Field must be filled |
| `minlength` / `maxlength` | Character limits |
| `pattern` | Regular expression validation |
| `min` / `max` | Numeric range |

```html
{( cn:preset.form.input 
    label="Postcode" 
    name="postcode" 
    pattern="[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}" 
    required=true 
)}
```

---

## Styling

All form presets are styled by `castd.css`. Customise via CSS variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `--input-border-width` | 1px | Border width |
| `--input-border` | `var(--border)` | Border colour |
| `--input-radius` | 10px | Corner radius |
| `--input-background` | `var(--control)` | Background colour |
| `--input-color` | `var(--text)` | Text colour |

---

## See Also

- [UI Presets](../ui/index.md) — Display components
- [Layout Presets](../layout/index.md) — Page structure

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
