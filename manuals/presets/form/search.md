# cn:preset.form.search

Search input field with clear button support.

## Usage

```html
{( cn:preset.form.search name="q" placeholder="Search..." )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text (often visually hidden for search) |
| `id` | string | — | Element ID |
| `name` | string | — | Form field name |
| `placeholder` | string | — | Placeholder text |
| `value` | string | — | Initial search term |
| `minlength` | number | — | Minimum search length |
| `maxlength` | number | — | Maximum search length |
| `pattern` | string | — | Regex validation pattern |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable search |
| `autofocus` | boolean | — | Focus on page load |

## Output

```html
<input type="search" name="q" placeholder="Search...">
```

## Styling

Search input styling is provided by `castd.css`. Browsers typically add a clear button (×) when the field has content.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity

## Examples

### Basic Search

```html
{( cn:preset.form.search name="q" placeholder="Search..." )}
```

### With Label

```html
{( cn:preset.form.search 
    label="Search products" 
    name="search" 
    placeholder="Enter product name..." 
)}
```

### Autofocus Search

```html
{( cn:preset.form.search 
    name="q" 
    placeholder="Type to search..." 
    autofocus=true 
)}
```

### In Header/Nav

```html
<nav>
    <a href="/">Home</a>
    <form role="search" action="/search">
        {( cn:preset.form.search name="q" placeholder="Search..." )}
    </form>
</nav>
```

## Live Search

For instant search results:

```javascript
const search = document.querySelector('input[type="search"]');
let timeout;

search.addEventListener('input', () => {
    clearTimeout(timeout);
    timeout = setTimeout(async () => {
        const results = await fetch(`/api/search?q=${search.value}`).then(r => r.json());
        renderResults(results);
    }, 300);
});
```

## Accessibility

For search forms, use `role="search"` on the containing form:

```html
<form role="search" action="/search">
    {( cn:preset.form.search name="q" placeholder="Search site..." )}
    {( cn:preset.form.button label="Search" type="submit" )}
</form>
```

## See Also

- [cn:preset.form.input](input.md) — General text input

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
