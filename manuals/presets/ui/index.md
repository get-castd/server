# UI Presets

Display and interactive interface components.

---

## Available Presets

| Preset | Description |
|--------|-------------|
| [alert](alert.md) | Alert notifications |
| [badge](badge.md) | Status badges and tags |
| [card](card.md) | Content cards |
| [dialog](dialog.md) | Modal dialogues |
| [dropdown](dropdown.md) | Dropdown menus |
| [accordion](accordion.md) | Collapsible sections |
| [tabs](tabs.md) | Tab navigation |
| [toast](toast.md) | Toast notifications |
| [wizard](wizard.md) | Multi-step wizard |
| [avatar](avatar.md) | User avatars |
| [chip](chip.md) | Interactive chips |
| [counter](counter.md) | Numeric counters |
| [pagination](pagination.md) | Page navigation |
| [skeleton](skeleton.md) | Loading skeletons |
| [tooltip](tooltip.md) | Tooltips |

---

## Usage

```html
{( cn:preset.ui.{component} content="..." )}
```

---

## State Classes

Many UI components support semantic state classes:

| Class | Purpose | Colour |
|-------|---------|--------|
| `is-info` | Informational | Blue |
| `is-success` | Positive outcome | Green |
| `is-warning` | Caution required | Amber |
| `is-error` | Error or danger | Red |

```html
{( cn:preset.ui.alert state="success" content="Operation complete." )}
{( cn:preset.ui.badge label="Active" state="success" )}
{( cn:preset.ui.toast message="Error occurred." state="error" )}
```

---

## Native Elements

UI presets favour native HTML elements where possible:

| Preset | Native Element |
|--------|----------------|
| dialog | `<dialog>` |
| dropdown | `<details>` / `<summary>` |
| accordion | `<details>` / `<summary>` |
| tabs | `<input type="radio">` |

This provides built-in accessibility, keyboard navigation, and reduces
JavaScript requirements.

---

## Example: Dashboard

```html
{( cn:preset.layout.container content="
    {( cn:preset.ui.alert state='info' content='Welcome back!' )}
    
    {( cn:preset.layout.grid columns='3' content='
        {( cn:preset.ui.card header=\"Users\" content=\"1,234\" )}
        {( cn:preset.ui.card header=\"Revenue\" content=\"£12,345\" )}
        {( cn:preset.ui.card header=\"Orders\" content=\"56\" )}
    ' )}
" )}
```

---

## See Also

- [Form Presets](../form/index.md) — Form elements
- [Layout Presets](../layout/index.md) — Page structure

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
