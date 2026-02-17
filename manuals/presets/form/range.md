# cn:preset.form.range

Range slider input for numeric value selection.

## Usage

```html
{( cn:preset.form.range label="Volume" name="volume" min="0" max="100" value="50" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text |
| `id` | string | — | Element ID (links label to input) |
| `name` | string | — | Form field name |
| `value` | number | — | Initial value |
| `min` | number | — | Minimum value |
| `max` | number | — | Maximum value |
| `step` | number | — | Step increment |
| `disabled` | boolean | — | Disable slider |

## Output

```html
<label for="volume">Volume</label>
<input type="range" id="volume" name="volume" min="0" max="100" value="50">
```

## Styling

Range slider is styled by `castd.css` with a custom track and thumb.

### Custom Properties

| Property | Description |
|----------|-------------|
| `--range-track-height` | Track thickness |
| `--range-thumb-size` | Thumb diameter |
| `--range-track-color` | Track background |
| `--range-fill-color` | Filled portion colour |

### States

- `:focus` — Focus ring on thumb
- `:disabled` — Reduced opacity
- `:active` — Thumb pressed state

## Examples

### Basic Slider

```html
{( cn:preset.form.range label="Brightness" name="brightness" min="0" max="100" )}
```

### With Steps

```html
{( cn:preset.form.range 
    label="Rating" 
    name="rating" 
    min="1" 
    max="5" 
    step="1" 
    value="3" 
)}
```

### Percentage

```html
{( cn:preset.form.range 
    label="Opacity" 
    name="opacity" 
    min="0" 
    max="1" 
    step="0.1" 
    value="1" 
)}
```

## JavaScript Integration

To display the current value:

```javascript
const range = document.querySelector('input[name="volume"]');
const output = document.querySelector('#volume-value');

range.addEventListener('input', () => {
    output.textContent = range.value;
});
```

## See Also

- [cn:preset.form.input](input.md) — Text/number input
- [cn:preset.form.progress](progress.md) — Progress indicator (planned)
- [cn:preset.form.meter](meter.md) — Meter indicator (planned)

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
