# cn:preset.form.progress

Progress bar for showing completion status.

## Usage

```html
{( cn:preset.form.progress value="75" max="100" label="Upload progress" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | number | — | Current progress value (omit for indeterminate) |
| `max` | number | `100` | Maximum value |
| `label` | string | — | Accessible label |
| `id` | string | — | Element ID |
| `style` | string | — | Inline CSS styles |

## Output

```html
<label for="upload">Upload progress</label>
<progress id="upload" value="75" max="100">75%</progress>
```

## Styling

Uses native `<progress>` element styled by `castd.css`.

## Examples

### Basic Progress

```html
{( cn:preset.form.progress value="50" max="100" )}
```

### Upload Progress

```html
{( cn:preset.form.progress 
    id="upload-progress" 
    value="0" 
    max="100" 
    label="Uploading file..." 
)}
```

### Indeterminate

```html
{( cn:preset.form.progress label="Loading..." )}
```

When `value` is omitted, the progress bar shows an indeterminate animation.

## JavaScript Integration

```javascript
const progress = document.getElementById('upload-progress');

async function upload(file) {
    const response = await fetch('/upload', {
        method: 'POST',
        body: file,
        onUploadProgress: (e) => {
            progress.value = (e.loaded / e.total) * 100;
        }
    });
}
```

## See Also

- [cn:preset.form.meter](meter.md) — Meter gauge
- [cn:preset.form.range](range.md) — Range slider

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
