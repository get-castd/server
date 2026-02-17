# cn:preset.form.select

Dropdown select input for choosing from predefined options.

## Usage

```html
{( cn:preset.form.select 
    label="Country" 
    name="country" 
    placeholder="Select a country" 
    options='<option value="uk">United Kingdom</option><option value="de">Germany</option>' 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text |
| `id` | string | — | Element ID (links label to select) |
| `name` | string | — | Form field name |
| `placeholder` | string | — | Placeholder text (disabled first option) |
| `options` | string | **Required** | HTML `<option>` elements |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable select |
| `multiple` | boolean | — | Allow multiple selections |

## Output

```html
<label for="country">Country</label>
<select id="country" name="country">
    <option value="" disabled selected>Select a country</option>
    <option value="uk">United Kingdom</option>
    <option value="de">Germany</option>
</select>
```

## Styling

Select styling is provided by `castd.css` with a custom dropdown arrow.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity
- `:invalid` — Error styling (when required and empty)

## Examples

### Basic Select

```html
{( cn:preset.form.select 
    label="Size" 
    name="size" 
    options='<option value="s">Small</option><option value="m">Medium</option><option value="l">Large</option>' 
)}
```

### With Placeholder

```html
{( cn:preset.form.select 
    label="Department" 
    name="dept" 
    placeholder="Choose department..." 
    required=true 
    options='<option value="sales">Sales</option><option value="eng">Engineering</option><option value="hr">HR</option>' 
)}
```

### Multiple Selection

```html
{( cn:preset.form.select 
    label="Skills" 
    name="skills" 
    multiple=true 
    options='<option value="js">JavaScript</option><option value="py">Python</option><option value="rs">Rust</option><option value="go">Go</option>' 
)}
```

### With Option Groups

```html
{( cn:preset.form.select 
    label="Vehicle" 
    name="vehicle" 
    options='<optgroup label="Cars"><option value="sedan">Sedan</option><option value="suv">SUV</option></optgroup><optgroup label="Bikes"><option value="road">Road</option><option value="mtb">Mountain</option></optgroup>' 
)}
```

## Dynamic Options

For dynamic options populated via JavaScript:

```javascript
const select = document.querySelector('select[name="country"]');
const countries = await fetch('/api/countries').then(r => r.json());

countries.forEach(c => {
    const option = document.createElement('option');
    option.value = c.code;
    option.textContent = c.name;
    select.appendChild(option);
});
```

## See Also

- [cn:preset.form.radio](radio.md) — Radio buttons alternative
- [cn:preset.ui.dropdown](../ui/dropdown.md) — Custom dropdown component

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
