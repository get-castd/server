# cn:preset.form.radio

Radio button for single selection from a group.

## Usage

```html
{( cn:preset.form.radio label="Small" name="size" value="s" )}
{( cn:preset.form.radio label="Medium" name="size" value="m" checked=true )}
{( cn:preset.form.radio label="Large" name="size" value="l" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | **Required** | Radio button label |
| `id` | string | — | Element ID |
| `name` | string | **Required** | Group name (shared across options) |
| `value` | string | **Required** | Value when selected |
| `checked` | boolean | — | Initially selected |
| `required` | boolean | — | Mark group as required |
| `disabled` | boolean | — | Disable option |

## Output

```html
<label>
    <input type="radio" name="size" value="m" checked>
    Medium
</label>
```

## Styling

Radio button styling is provided by `castd.css`. The native radio is visually hidden and replaced with a custom circular indicator.

### States

- `:checked` — Inner dot visible
- `:focus` — Focus ring
- `:disabled` — Reduced opacity

## Examples

### Basic Radio Group

```html
<fieldset>
    <legend>Select size</legend>
    {( cn:preset.form.radio label="Small" name="size" value="s" )}
    {( cn:preset.form.radio label="Medium" name="size" value="m" )}
    {( cn:preset.form.radio label="Large" name="size" value="l" )}
</fieldset>
```

### Segment Style

For a segmented control appearance, wrap in `.as-segments`:

```html
<fieldset class="as-segments">
    <legend class="sr-only">View mode</legend>
    {( cn:preset.form.radio label="List" name="view" value="list" checked=true )}
    {( cn:preset.form.radio label="Grid" name="view" value="grid" )}
    {( cn:preset.form.radio label="Cards" name="view" value="cards" )}
</fieldset>
```

### Tab Style

For tab-like appearance, use `.as-tabs`:

```html
<fieldset class="as-tabs">
    <legend class="sr-only">Section</legend>
    {( cn:preset.form.radio label="Details" name="tab" value="details" checked=true )}
    {( cn:preset.form.radio label="Reviews" name="tab" value="reviews" )}
    {( cn:preset.form.radio label="Related" name="tab" value="related" )}
</fieldset>
```

## See Also

- [cn:preset.form.checkbox](checkbox.md) — Multiple selection
- [cn:preset.form.select](select.md) — Dropdown alternative
- [cn:preset.form.segment](segment.md) — Segmented control (planned)

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
