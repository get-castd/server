# Presets

Presets are server-rendered components that generate clean HTML. They are
processed by the CAST template engine and styled by `castd.css`.

---

## Syntax

```html
{( cn:preset.{category}.{name} param="value" )}
```

Presets use the `{( )}` delimiter. Parameters are passed as key-value pairs.
See the [CAST Reference](../05-cast-reference.md) for complete syntax details.

---

## Categories

### Form Components

Interactive form elements for user input.

| Preset | Description |
|--------|-------------|
| [button](form/button.md) | Buttons and submit controls |
| [input](form/input.md) | Text input fields |
| [password](form/password.md) | Password input with visibility toggle |
| [search](form/search.md) | Search input |
| [textarea](form/textarea.md) | Multi-line text |
| [checkbox](form/checkbox.md) | Checkbox (toggle switch style) |
| [radio](form/radio.md) | Radio buttons |
| [range](form/range.md) | Range slider |
| [select](form/select.md) | Dropdown select |
| [file](form/file.md) | File upload |
| [progress](form/progress.md) | Progress bar |
| [meter](form/meter.md) | Meter gauge |
| [segment](form/segment.md) | Segmented control |

### UI Components

Display and interactive interface elements.

| Preset | Description |
|--------|-------------|
| [alert](ui/alert.md) | Alert notifications |
| [badge](ui/badge.md) | Status badges and tags |
| [card](ui/card.md) | Content cards |
| [dialog](ui/dialog.md) | Modal dialogues |
| [dropdown](ui/dropdown.md) | Dropdown menus |
| [accordion](ui/accordion.md) | Collapsible sections |
| [tabs](ui/tabs.md) | Tab navigation |
| [toast](ui/toast.md) | Toast notifications |
| [wizard](ui/wizard.md) | Multi-step wizard |
| [avatar](ui/avatar.md) | User avatars |
| [chip](ui/chip.md) | Interactive chips |
| [counter](ui/counter.md) | Numeric counters |
| [pagination](ui/pagination.md) | Page navigation |
| [skeleton](ui/skeleton.md) | Loading skeletons |
| [tooltip](ui/tooltip.md) | Tooltips |

### Layout Components

Page structure and layout.

| Preset | Description |
|--------|-------------|
| [header](layout/header.md) | Site header |
| [nav](layout/nav.md) | Navigation menu |
| [sidebar](layout/sidebar.md) | Side panel |
| [footer](layout/footer.md) | Site footer |
| [container](layout/container.md) | Width constraint |
| [grid](layout/grid.md) | CSS grid layout |
| [breadcrumb](layout/breadcrumb.md) | Breadcrumb navigation |

---

## Creating Custom Presets

Presets are HTML files with CAST templating:

```html
{# my.custom.preset — Description #}
<div class="my-component"
    {! if id !}id="{{ id }}"{! endif !}>
    {{ content | raw }}
</div>
```

### Shebang Comment

The first line defines the preset:

```html
{# namespace.name — Description #}
```

### Templating Syntax

| Syntax | Purpose |
|--------|---------|
| `{{ variable }}` | Output (HTML-escaped) |
| `{{ variable \| raw }}` | Output (unescaped HTML) |
| `{{ variable \| default="value" }}` | Default value |
| `{! if condition !}...{! endif !}` | Conditional |
| `{! if condition !}...{! else !}...{! endif !}` | Conditional with else |

### File Structure

```
presets/components/
└── my/custom/preset/
    ├── preset.html    # Template (required)
    ├── preset.css     # Styles (optional)
    └── preset.js      # Behaviour (optional)
```

---

## See Also

- [Concepts](../03-concepts.md) — Class naming and CSS layers
- [CAST Reference](../05-cast-reference.md) — Template language specification
- [Styling](../07-styling.md) — CSS framework reference

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
