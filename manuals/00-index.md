# CASTD — Documentation

> Maximum functionality, minimum resources.

CASTD is a stackless webserver: HTTP, templates, styling, persistence, and
extensions in a single binary. Use the CSS framework standalone, or combine
it with the server for a complete application stack.

---

## Reading Order

| # | Document | Contents |
|---|----------|----------|
| 1 | [Introduction](01-introduction.md) | What CASTD is, stack comparison, honest limitations |
| 2 | [Getting Started](02-getting-started.md) | Installation, configuration, first bundle, deployment |
| 3 | [Concepts](03-concepts.md) | Class prefixes, CSS layers, file naming |
| 4 | [CAST Tutorial](04-cast.md) | Gentle introduction to the five syntax types |
| 5 | [CAST Reference](05-cast-reference.md) | Complete language specification |
| 6 | [CAST Grammar](06-cast-grammar.md) | Formal EBNF grammar |
| 7 | [Styling](07-styling.md) | castd.css — grid, typography, forms, components |
| 8 | [Scripting](08-scripting.md) | castd.js — data bus, i18n, preferences, theme |
| 9 | [Theming](09-theming.md) | OKLCH, Metroline, dark mode, custom themes, variables |
| 10 | [Presets](10-presets.md) | Preset system: syntax, resolution, slots, snippets |
| 11 | [Persistence](11-persistence.md) | SQLite CRUD, auth, access control, volumes |
| 12 | [Context](12-context.md) | Tag-based context system |

| 13 | [Business Model](13-business.md) | Licensing and commercial offering |

### Reference

| Document | Contents |
|----------|----------|
| [Preset Reference](presets/) | Individual preset documentation (form, UI, layout) |

---

## Architecture: LEAT

CASTD follows the **LEAT** pattern (Linear Event-Actor-Turnback):

1. **Event** — A request arrives (HTTP, WebSocket message, form submission)
2. **Actor** — A handler processes it (template rendering, database query, business logic)
3. **Turnback** — A response returns (HTML, JSON, redirect)

No circular dependencies. Each request is a straight line from input to output.

---

## Quick Start

### CSS Only (Standalone)

```html
<!DOCTYPE html>
<html lang="en-GB">
<head>
    <meta charset="UTF-8">
    <meta name="color-scheme" content="light dark">
    <link rel="stylesheet" href="castd.css">
</head>
<body>
    <article class="as-card show-shadow">
        <header>Welcome</header>
        <p>Your content here.</p>
    </article>
</body>
</html>
```

### Full Stack

```bash
./castd/castd.sh start --bundle my-site
# Visit http://127.0.0.1:1337
```

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
