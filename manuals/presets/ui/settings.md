# cn:preset.ui.settings

Settings wizard dialog for user preferences (cookies, theme, language, notifications).

## Usage

```html
{( cn:preset.ui.settings 
    cookies=true 
    theme=true 
    language=true 
)}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | string | `"settings-dialog"` | Dialog element ID |
| `cookies` | boolean | `false` | Enable cookie consent slide |
| `cookies_api` | string | — | API endpoint for cookie consent |
| `theme` | boolean | `false` | Enable theme/appearance slide |
| `fontsize` | boolean | `false` | Enable font size options (within theme slide) |
| `language` | boolean | `false` | Enable language selection slide |
| `languages` | string | — | Custom language options (HTML `<option>` tags) |
| `notifications` | boolean | `false` | Enable notifications slide |
| `custom_slides` | string | — | Additional custom slides (raw HTML) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<dialog id="settings-dialog" class="as-settings-dialog" aria-labelledby="settings-dialog-title" aria-modal="true">
    <div class="as-wizard" id="settings-dialog-wizard">
        <section>
            <div class="settings-slide" data-slide="cookies">
                <h2 id="settings-dialog-title" data-ml="settingsCookiesTitle">Cookies</h2>
                <p data-ml="settingsCookiesDesc">Choose which cookies we may use.</p>
                <fieldset>
                    <label>
                        <span data-ml="settingsCookiesEssential">Essential</span>
                        <input type="checkbox" name="cookies-essential" checked disabled>
                    </label>
                    <label>
                        <span data-ml="settingsCookiesAnalytics">Analytics</span>
                        <input type="checkbox" name="cookies-analytics">
                    </label>
                    <label>
                        <span data-ml="settingsCookiesMarketing">Marketing</span>
                        <input type="checkbox" name="cookies-marketing">
                    </label>
                </fieldset>
            </div>
            <!-- Additional slides based on parameters -->
        </section>
    </div>
</dialog>
```

## Predefined Modules

### Cookies Module (`cookies=true`)

Cookie consent with three categories:

| Category | Description | User Control |
|----------|-------------|--------------|
| Essential | Required for site function | Always enabled, disabled checkbox |
| Analytics | Usage tracking | Optional |
| Marketing | Advertising cookies | Optional |

Set `cookies_api` to POST consent data to your backend:

```html
{( cn:preset.ui.settings 
    cookies=true 
    cookies_api="/api/consent" 
)}
```

The API receives JSON:
```json
{
    "essential": true,
    "analytics": true,
    "marketing": false
}
```

### Theme Module (`theme=true`)

Appearance settings:

- **Dark mode toggle** — Switches `colorScheme` on `<html>`
- **Font size** (optional, enable with `fontsize=true`) — Small, Default, Large

```html
{( cn:preset.ui.settings 
    theme=true 
    fontsize=true 
)}
```

### Language Module (`language=true`)

Language selection with 16 default languages:

| Code | Language |
|------|----------|
| `en-GB` | English |
| `de-DE` | Deutsch |
| `nl-NL` | Nederlands |
| `fr-FR` | Français |
| `es-ES` | Español |
| `pt-PT` | Português |
| `it-IT` | Italiano |
| `ru-RU` | Русский |
| `ar-SA` | العربية |
| `zh-CN` | 中文 |
| `ko-KR` | 한국어 |
| `ja-JP` | 日本語 |
| `eu-ES` | Euskara |
| `ca-ES` | Català |
| `ga-IE` | Gaeilge |
| `gd-GB` | Gàidhlig |

#### Custom Language List

Override defaults with the `languages` parameter:

```html
{( cn:preset.ui.settings 
    language=true 
    languages="<option value='en-GB'>English</option><option value='de-DE'>Deutsch</option><option value='fr-FR'>Français</option>" 
)}
```

### Notifications Module (`notifications=true`)

Notification preferences:

- **Email notifications** — Toggle
- **Push notifications** — Toggle

## Custom Slides

Add custom slides with the `custom_slides` parameter:

```html
{( cn:preset.ui.settings 
    cookies=true 
    theme=true 
    custom_slides="<div class='settings-slide' data-slide='privacy'><h2>Privacy</h2><p>Additional privacy settings.</p><fieldset><label><span>Do Not Track</span><input type='checkbox' name='dnt' role='switch'></label></fieldset></div>" 
)}
```

## JavaScript API

The dialog exposes an API on the element:

```javascript
// Get the dialog
const dialog = document.getElementById("settings-dialog");

// Open the dialog
dialog.cnSettings.open();

// Get current preferences
const prefs = dialog.cnSettings.getPrefs();

// Save preferences programmatically
await dialog.cnSettings.save();

// Apply preferences without saving
dialog.cnSettings.applyPrefs(prefs);
```

### Global Access

```javascript
// Access via global object
window.cnSettings["settings-dialog"].open();
```

## Events

| Event | Target | Description |
|-------|--------|-------------|
| `cn:settings-saved` | `<dialog>` | Fired after preferences are saved |
| `cn:wizard-save` | Wizard element | Triggered by wizard's save action |

```javascript
dialog.addEventListener("cn:settings-saved", (e) => {
    console.log("Saved preferences:", e.detail.prefs);
});
```

## Data Attributes

Configure via data attributes on the dialog:

| Attribute | Description | Default |
|-----------|-------------|---------|
| `data-cookie-name` | Cookie name for preferences | `"cn_prefs"` |
| `data-cookie-days` | Cookie expiry in days | `365` |
| `data-cookies-api` | API endpoint for consent | — |

## Styling

Settings dialog styling is provided by `settings.css`.

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--surface` | Dialog background |
| `--text` | Text colour |
| `--muted` | Secondary text colour |
| `--control` | Control background |
| `--unit` | Spacing unit |

### Structure Classes

| Class | Purpose |
|-------|---------|
| `.as-settings-dialog` | Main dialog container |
| `.settings-slide` | Individual slide |
| `.as-wizard` | Wizard wrapper (from framework) |
| `.as-segments` | Segmented control (font size) |

## Examples

### Minimal — Cookie Consent Only

```html
{( cn:preset.ui.settings cookies=true )}
```

### Full Settings

```html
{( cn:preset.ui.settings 
    id="site-settings"
    cookies=true 
    cookies_api="/api/consent"
    theme=true 
    fontsize=true
    language=true 
    notifications=true 
)}
```

### With Custom Languages

```html
{( cn:preset.ui.settings 
    language=true 
    languages="<option value='en-GB'>English</option><option value='de-DE'>Deutsch</option>" 
)}
```

### Opening the Dialog

```html
<button onclick="document.getElementById('settings-dialog').cnSettings.open()">
    Settings
</button>
```

Or with a custom trigger:

```html
<button onclick="window.cnSettings['settings-dialog'].open()">
    ⚙️ Preferences
</button>
```

## Integration with castd.js

The settings wizard integrates with castd.js for i18n:

- All text elements have `data-cn-translate` attributes
- Language changes call `cn.i18n.switchLang()`
- Wizard section is cached for language switching

## Preferences Storage

Preferences are stored in a cookie with this structure:

```json
{
    "cookies": {
        "essential": true,
        "analytics": true,
        "marketing": false
    },
    "theme": "dark",
    "fontSize": "md",
    "lang": "en-GB",
    "notifications": {
        "email": true,
        "push": false
    }
}
```

## Accessibility

- Dialog uses `aria-modal="true"` and `aria-labelledby`
- All form controls are properly labelled
- Focus is trapped within the dialog when open
- Switches use `role="switch"` for screen readers
- Essential cookies checkbox is disabled but checked (required, not optional)

## See Also

- [cn:preset.ui.dialog](dialog.md) — Base dialog component
- [Scripting](../../08-scripting.md) — Client-side JavaScript documentation
- [Theming](../../09-theming.md) — Theme customisation

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
