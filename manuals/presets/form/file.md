# cn:preset.form.file

File upload input.

## Usage

```html
{( cn:preset.form.file label="Upload document" name="document" accept=".pdf,.doc,.docx" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text |
| `id` | string | — | Element ID |
| `name` | string | — | Form field name |
| `accept` | string | — | Accepted file types (MIME or extensions) |
| `multiple` | boolean | — | Allow multiple files |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable input |

## Output

```html
<label for="document">Upload document</label>
<input type="file" id="document" name="document" accept=".pdf,.doc,.docx">
```

## Styling

File input styling is provided by `castd.css`. The native file button is styled to match other form elements.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity

## Examples

### Basic File Upload

```html
{( cn:preset.form.file label="Attachment" name="attachment" )}
```

### Image Upload

```html
{( cn:preset.form.file 
    label="Profile photo" 
    name="photo" 
    accept="image/*" 
)}
```

### Multiple Files

```html
{( cn:preset.form.file 
    label="Upload images" 
    name="images" 
    accept="image/png,image/jpeg" 
    multiple=true 
)}
```

### Specific Extensions

```html
{( cn:preset.form.file 
    label="Spreadsheet" 
    name="spreadsheet" 
    accept=".xlsx,.csv" 
    required=true 
)}
```

## Accept Values

| Pattern | Matches |
|---------|---------|
| `image/*` | All image types |
| `video/*` | All video types |
| `audio/*` | All audio types |
| `.pdf` | PDF files |
| `.doc,.docx` | Word documents |
| `image/png,image/jpeg` | Specific image types |

## File Preview

To show selected file names:

```javascript
const input = document.querySelector('input[type="file"]');
const preview = document.querySelector('#file-preview');

input.addEventListener('change', () => {
    const files = Array.from(input.files);
    preview.innerHTML = files.map(f => `<li>${f.name} (${formatSize(f.size)})</li>`).join('');
});

function formatSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}
```

## Drag and Drop

For drag-and-drop upload zones, combine with custom styling:

```html
<div class="drop-zone" ondrop="handleDrop(event)" ondragover="event.preventDefault()">
    {( cn:preset.form.file label="Drop files here or click to browse" name="files" multiple=true )}
</div>
```

## See Also

- [cn:preset.form.input](input.md) — Text input

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
