# Scripting

castd.js — minimal client-side utilities providing five modules: Data-Bus,
i18n, Preferences, Theme, and Code.

**Size:** Approximately 4 KB

---

## Namespace

All functionality is exposed under the `cn` namespace:

```javascript
cn.data    // Data-Bus (centralised state)
cn.i18n    // Internationalisation
cn.prefs   // Preferences (localStorage)
cn.theme   // Theme toggle
cn.code    // Code block line numbers

cn.get()   // Shortcut for cn.data.get()
cn.set()   // Shortcut for cn.data.set()
```

---

## Data-Bus

Centralised state management for client-side values.

### Store Structure

```javascript
cn.data.store = {
    i18n: {
        page: {},           // { lang: { key: value } }
        lang: "en-GB"       // Current language
    },
    prefs: {
        theme: null,        // "light" | "dark"
        lang: null          // User language preference
    }
};
```

### Reading and Writing Values

```javascript
// Read a value at a path
cn.get("i18n.lang");           // → "en-GB"
cn.get("prefs.theme");         // → "dark"

// Write a value at a path
cn.set("prefs.theme", "light");
cn.set("i18n.lang", "de-DE");
```

### Direct Access

For performance-critical code, access the store directly:

```javascript
cn.data.store.i18n.lang = "de-DE";
const theme = cn.data.store.prefs.theme;
```

### Design Principles

**Single source of truth** — All client state lives in `cn.data.store`.

**Path-based access** — Dot notation (`"i18n.lang"`) provides structured access.

**No events** — Read and write directly. No observers, no subscriptions.

**Fixed structure** — The store shape is predefined, not arbitrary.

---

## Internationalisation

Runtime language switching without external dependencies.

### CSV Format

```csv
key;value;lang
title;Welcome;en-GB
title;Willkommen;de-DE
submit;Submit;en-GB
submit;Absenden;de-DE
```

- Semicolon-separated (not comma)
- Three columns: key, value, language code
- BCP 47 language tags: `en-GB`, `de-DE`, `fr-FR`

### API

| Method | Purpose |
|--------|---------|
| `cn.i18n.lang()` | Get current language |
| `cn.i18n.lang("de-DE")` | Set current language |
| `cn.i18n.t("key")` | Get translation for key |
| `cn.i18n.load(src)` | Load translations from CSV file |
| `cn.i18n.apply(root?)` | Apply translations to `[data-ml]` elements |
| `cn.i18n.switchLang(lang)` | Switch language and reload page |
| `cn.i18n.init()` | Initialise from localStorage |

### Usage

```html
<h1 data-ml="title">Welcome</h1>
<button data-ml="submit">Submit</button>

<script>
    cn.i18n.load("translations.csv").then(() => cn.i18n.apply());
</script>
```

### Translation Lookup Order

When `cn.i18n.t("key")` is called:

1. Search `cn.i18n.page[currentLang]`
2. Fall back to `en-GB`
3. Return the key unchanged if not found

### Language Switching

```javascript
// Switches language, saves to localStorage, reloads page
cn.i18n.switchLang("de-DE");
```

---

## Preferences

localStorage-backed user settings.

### API

| Method | Purpose |
|--------|---------|
| `cn.prefs.get(key)` | Read a preference |
| `cn.prefs.set(key, value)` | Write a preference |
| `cn.prefs.remove(key)` | Delete a preference |
| `cn.prefs.init()` | Load saved preferences into store |

### Usage

```javascript
// Save a preference
cn.prefs.set("theme", "dark");

// Read a preference
const theme = cn.prefs.get("theme");  // → "dark"

// Remove a preference
cn.prefs.remove("theme");
```

### Storage Keys

All preferences are stored with a `cn-` prefix:

| Key | localStorage Key |
|-----|------------------|
| `theme` | `cn-theme` |
| `lang` | `cn-lang` |

---

## Theme

Toggle between light and dark mode.

### API

| Method | Purpose |
|--------|---------|
| `cn.theme.get()` | Get current theme |
| `cn.theme.set(value)` | Set theme ("light" or "dark") |
| `cn.theme.toggle()` | Toggle between light and dark |
| `cn.theme.init()` | Apply saved theme on load |

### Usage

```javascript
// Toggle theme
cn.theme.toggle();

// Set specific theme
cn.theme.set("dark");

// Get current theme
const current = cn.theme.get();  // → "dark"
```

### Implementation

The theme is stored as a `data-theme` attribute on `<html>`:

```html
<html data-theme="dark">
```

The CSS framework reads this attribute for theme-specific styles when needed.

---

## Auto-Initialisation

On load, castd.js automatically:

1. `cn.prefs.init()` — Loads saved preferences from localStorage
2. `cn.theme.init()` — Applies the saved theme
3. `cn.i18n.init()` — Sets language from localStorage
4. `cn.code.init()` — Wraps `<pre><code>` lines with `<span data-line>`

No manual initialisation is required.

---

## Complete Example

```html
<!DOCTYPE html>
<html lang="en-GB">
<head>
    <meta charset="UTF-8">
    <meta name="color-scheme" content="light dark">
    <link rel="stylesheet" href="/assets/styles/castd.css">
</head>
<body>
    <h1 data-ml="welcome">Welcome</h1>
    
    <button onclick="cn.theme.toggle()">Toggle Theme</button>
    <button onclick="cn.i18n.switchLang('de-DE')">Deutsch</button>
    
    <script src="/assets/scripts/castd.js"></script>
    <script>
        cn.i18n.load("/i18n/index.csv").then(() => cn.i18n.apply());
    </script>
</body>
</html>
```

---

## See Also

- [07-styling.md](07-styling.md) — CSS framework and design tokens
- [09-theming.md](09-theming.md) — Theme customisation and colour schemes
- [03-concepts.md](03-concepts.md) — Core CASTD concepts

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
