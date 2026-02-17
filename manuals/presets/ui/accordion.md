# cn:preset.ui.accordion

Collapsible content sections using native `<details>` elements.

## Usage

```html
{( cn:preset.ui.accordion content="
    <details>
        <summary>Section 1</summary>
        <p>Content for section 1</p>
    </details>
    <details>
        <summary>Section 2</summary>
        <p>Content for section 2</p>
    </details>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | `<details>` elements (supports HTML) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-accordion">
    <details>
        <summary>Section 1</summary>
        <p>Content for section 1</p>
    </details>
    <details>
        <summary>Section 2</summary>
        <p>Content for section 2</p>
    </details>
</div>
```

## Styling

Accordion styling is provided by `castd.css`. The wrapper applies consistent spacing and borders between sections.

## Examples

### Basic FAQ

```html
{( cn:preset.ui.accordion content="
    <details>
        <summary>What is CASTD?</summary>
        <p>A lightweight CSS framework with a snippet system.</p>
    </details>
    <details>
        <summary>How do I install it?</summary>
        <p>Include castd.css and castd.js in your project.</p>
    </details>
    <details>
        <summary>Is it free?</summary>
        <p>Yes, CASTD is open source under Apache 2.0.</p>
    </details>
" )}
```

### With Open Section

```html
{( cn:preset.ui.accordion content="
    <details open>
        <summary>Getting Started</summary>
        <p>Welcome! Start here to learn the basics.</p>
    </details>
    <details>
        <summary>Advanced Topics</summary>
        <p>Deep dives into advanced features.</p>
    </details>
" )}
```

### Rich Content

```html
{( cn:preset.ui.accordion content="
    <details>
        <summary>Shipping Information</summary>
        <ul>
            <li>Standard: 3-5 business days</li>
            <li>Express: 1-2 business days</li>
            <li>Same day: Available in select areas</li>
        </ul>
    </details>
    <details>
        <summary>Return Policy</summary>
        <p>30-day returns on all items. <a href='/returns'>Full policy</a></p>
    </details>
" )}
```

## JavaScript: Single Open

To allow only one section open at a time:

```javascript
document.querySelectorAll('.as-accordion details').forEach(detail => {
    detail.addEventListener('toggle', () => {
        if (detail.open) {
            detail.parentElement.querySelectorAll('details[open]').forEach(other => {
                if (other !== detail) other.removeAttribute('open');
            });
        }
    });
});
```

## Accessibility

- Uses native `<details>/<summary>` for built-in accessibility
- Keyboard navigation: Tab to focus, Enter/Space to toggle
- Screen readers announce expanded/collapsed state

## See Also

- [cn:preset.ui.tabs](tabs.md) — Tab-based navigation
- [cn:preset.ui.dropdown](dropdown.md) — Dropdown menus

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
