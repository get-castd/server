# cn:preset.ui.counter

Numeric counter with increment/decrement controls.

## Usage

```html
{( cn:preset.ui.counter name="quantity" value="1" min="1" max="10" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | string | — | Form field name |
| `id` | string | — | Element ID |
| `value` | number | `0` | Initial value |
| `min` | number | — | Minimum value |
| `max` | number | — | Maximum value |
| `step` | number | `1` | Increment step |
| `disabled` | boolean | — | Disabled state |
| `label` | string | — | Accessible label |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-counter">
    <label for="qty">Quantity</label>
    <div class="counter-controls">
        <button type="button" class="counter-decrement" aria-label="Decrease">−</button>
        <input type="number" id="qty" name="quantity" value="1" min="1" max="10">
        <button type="button" class="counter-increment" aria-label="Increase">+</button>
    </div>
</div>
```

## Styling

Counter styling is provided by `counter.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--counter-btn-bg` | Button background |
| `--counter-btn-color` | Button text colour |
| `--counter-input-width` | Input width |
| `--counter-border` | Border colour |
| `--counter-radius` | Border radius |

## Examples

### Quantity Selector

```html
{( cn:preset.ui.counter 
    label="Quantity" 
    name="qty" 
    value="1" 
    min="1" 
    max="99" 
)}
```

### With Step

```html
{( cn:preset.ui.counter 
    name="amount" 
    value="100" 
    step="10" 
    min="0" 
    max="1000" 
)}
```

### Disabled

```html
{( cn:preset.ui.counter 
    name="fixed" 
    value="5" 
    disabled=true 
)}
```

## JavaScript

Counter behaviour is provided by `counter.js`. The script automatically handles:

- Increment/decrement button clicks
- Min/max boundary enforcement
- Step increments
- Change event dispatching

## See Also

- [cn:preset.form.range](../form/range.md) — Range slider
- [cn:preset.form.input](../form/input.md) — Number input

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
