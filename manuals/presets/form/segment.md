# cn:preset.form.segment

Segmented control for mutually exclusive options.

## Usage

```html
{( cn:preset.form.segment legend="View mode" content="
    <label><input type='radio' name='view' value='list' checked><span>List</span></label>
    <label><input type='radio' name='view' value='grid'><span>Grid</span></label>
    <label><input type='radio' name='view' value='cards'><span>Cards</span></label>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Radio labels with inputs |
| `legend` | string | — | Accessible legend (visually hidden) |
| `stretch` | boolean | — | Full-width segments (`like-stretch`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<fieldset class="as-segments">
    <legend class="sr-only">View mode</legend>
    <label><input type="radio" name="view" value="list" checked><span>List</span></label>
    <label><input type="radio" name="view" value="grid"><span>Grid</span></label>
    <label><input type="radio" name="view" value="cards"><span>Cards</span></label>
</fieldset>
```

## Styling

Segment styling is provided by `segment.css`. Radio inputs are visually hidden, with styled `<span>` elements appearing as a unified control.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--segments-background` | Container background |
| `--segments-radius` | Container border radius |
| `--segment-color` | Text colour |
| `--segment-hover-background` | Hover background |
| `--segment-active-background` | Selected background |
| `--segment-active-color` | Selected text colour |

## Examples

### View Switcher

```html
{( cn:preset.form.segment legend="View" content="
    <label><input type='radio' name='view' value='list' checked><span>📋 List</span></label>
    <label><input type='radio' name='view' value='grid'><span>⊞ Grid</span></label>
" )}
```

### Size Selector

```html
{( cn:preset.form.segment legend="Size" content="
    <label><input type='radio' name='size' value='s'><span>S</span></label>
    <label><input type='radio' name='size' value='m' checked><span>M</span></label>
    <label><input type='radio' name='size' value='l'><span>L</span></label>
    <label><input type='radio' name='size' value='xl'><span>XL</span></label>
" )}
```

### Full-Width

```html
{( cn:preset.form.segment stretch=true legend="Plan" content="
    <label><input type='radio' name='plan' value='monthly'><span>Monthly</span></label>
    <label><input type='radio' name='plan' value='yearly' checked><span>Yearly</span></label>
" )}
```

### Disabled Option

```html
<label><input type="radio" name="plan" value="enterprise" disabled><span>Enterprise</span></label>
```

## Accessibility

- Uses native `<fieldset>` with visually hidden `<legend>`
- Radio inputs provide keyboard navigation
- Focus states are visible on the styled spans

## See Also

- [cn:preset.form.radio](radio.md) — Radio buttons
- [cn:preset.ui.tabs](../ui/tabs.md) — Tab navigation

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
