# cn:preset.ui.tabs

Tab-based content navigation.

## Usage

```html
{( cn:preset.ui.tabs count="3" content="
    <input type='radio' name='tabs' id='tab1' checked>
    <label for='tab1'>Overview</label>
    <input type='radio' name='tabs' id='tab2'>
    <label for='tab2'>Details</label>
    <input type='radio' name='tabs' id='tab3'>
    <label for='tab3'>Reviews</label>
    <section>Overview content</section>
    <section>Details content</section>
    <section>Reviews content</section>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Tab structure (inputs, labels, sections) |
| `count` | number | **Required** | Number of tabs (sets `--tab-count`) |
| `vertical` | boolean | — | Vertical tab layout (`like-vertical`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-tabs" style="--tab-count: 3">
    <input type="radio" name="tabs" id="tab1" checked>
    <label for="tab1">Overview</label>
    <input type="radio" name="tabs" id="tab2">
    <label for="tab2">Details</label>
    <input type="radio" name="tabs" id="tab3">
    <label for="tab3">Reviews</label>
    <section>Overview content</section>
    <section>Details content</section>
    <section>Reviews content</section>
</div>
```

## Styling

Tab styling is provided by `castd.css`. The CSS uses the `:checked` state of hidden radio buttons to show/hide content sections.

### Structure

The content must follow this order:
1. Radio inputs (hidden)
2. Labels (tab buttons)
3. Sections (content panels)

## Examples

### Basic Tabs

```html
{( cn:preset.ui.tabs count="2" content="
    <input type='radio' name='demo-tabs' id='dt1' checked>
    <label for='dt1'>First</label>
    <input type='radio' name='demo-tabs' id='dt2'>
    <label for='dt2'>Second</label>
    <section><p>First panel content</p></section>
    <section><p>Second panel content</p></section>
" )}
```

### Vertical Tabs

```html
{( cn:preset.ui.tabs count="3" vertical=true content="
    <input type='radio' name='vtabs' id='vt1' checked>
    <label for='vt1'>Account</label>
    <input type='radio' name='vtabs' id='vt2'>
    <label for='vt2'>Security</label>
    <input type='radio' name='vtabs' id='vt3'>
    <label for='vt3'>Billing</label>
    <section>Account settings...</section>
    <section>Security settings...</section>
    <section>Billing settings...</section>
" )}
```

### Tabs with Icons

```html
{( cn:preset.ui.tabs count="3" content="
    <input type='radio' name='icon-tabs' id='it1' checked>
    <label for='it1'>📊 Dashboard</label>
    <input type='radio' name='icon-tabs' id='it2'>
    <label for='it2'>👤 Profile</label>
    <input type='radio' name='icon-tabs' id='it3'>
    <label for='it3'>⚙️ Settings</label>
    <section>Dashboard content</section>
    <section>Profile content</section>
    <section>Settings content</section>
" )}
```

## How It Works

The CSS-only tabs work via:

1. Radio inputs are visually hidden but functional
2. Labels act as clickable tab buttons
3. CSS `:checked` selector shows the corresponding section
4. `--tab-count` variable enables correct grid layout

```css
.as-tabs input:nth-of-type(1):checked ~ section:nth-of-type(1) {
    display: block;
}
```

## Accessibility

- Radio inputs provide native keyboard navigation
- Tab/Shift+Tab moves between tabs
- Arrow keys navigate within tab group
- Labels are associated with inputs via `for` attribute

## See Also

- [cn:preset.ui.accordion](accordion.md) — Collapsible sections
- [cn:preset.form.radio](../form/radio.md) — Radio button styling

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
