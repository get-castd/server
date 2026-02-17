# cn:preset.form.meter

Meter gauge for displaying scalar measurements within a known range.

## Usage

```html
{( cn:preset.form.meter value="0.7" min="0" max="1" low="0.3" high="0.7" optimum="0.8" label="Disk usage" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | number | **Required** | Current value |
| `min` | number | `0` | Minimum value |
| `max` | number | `1` | Maximum value |
| `low` | number | — | Low threshold |
| `high` | number | — | High threshold |
| `optimum` | number | — | Optimal value |
| `label` | string | — | Accessible label |
| `id` | string | — | Element ID |
| `style` | string | — | Inline CSS styles |

## Output

```html
<label for="disk">Disk usage</label>
<meter id="disk" value="0.7" min="0" max="1" low="0.3" high="0.7" optimum="0.8">70%</meter>
```

## Styling

Uses native `<meter>` element styled by `castd.css`.

### Colour Ranges

| Range | Colour |
|-------|--------|
| Below `low` | Green (if optimum is high) or red (if optimum is low) |
| Between `low` and `high` | Amber |
| Above `high` | Red (if optimum is low) or green (if optimum is high) |

## Examples

### Disk Usage (lower is better)

```html
{( cn:preset.form.meter 
    label="Disk usage" 
    value="0.85" 
    high="0.8" 
    optimum="0.2" 
)}
```

### Score (higher is better)

```html
{( cn:preset.form.meter 
    label="Performance score" 
    value="92" 
    min="0" 
    max="100" 
    low="50" 
    high="80" 
    optimum="100" 
)}
```

### Battery Level

```html
{( cn:preset.form.meter 
    label="Battery" 
    value="25" 
    min="0" 
    max="100" 
    low="20" 
    high="80" 
    optimum="100" 
)}
```

## Meter vs Progress

| Element | Use Case |
|---------|----------|
| `<progress>` | Task completion (determinate or indeterminate) |
| `<meter>` | Scalar measurement within a known range |

Use **meter** for: disk usage, relevance score, password strength, battery level.
Use **progress** for: upload progress, download progress, loading state.

## See Also

- [cn:preset.form.progress](progress.md) — Progress bar
- [cn:preset.form.range](range.md) — Range slider

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
