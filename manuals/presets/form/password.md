# cn:preset.form.password

Password input with autocomplete hints.

## Usage

```html
{( cn:preset.form.password label="Password" name="password" required=true )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | string | — | Label text |
| `id` | string | — | Element ID |
| `name` | string | — | Form field name |
| `placeholder` | string | — | Placeholder text |
| `required` | boolean | — | Mark as required |
| `disabled` | boolean | — | Disable input |
| `minlength` | number | — | Minimum password length |
| `maxlength` | number | — | Maximum password length |
| `autocomplete` | string | `"current-password"` | Autocomplete hint |
| `validate` | string | — | Custom validation rule |

## Output

```html
<label for="password">Password</label>
<input type="password" id="password" name="password" required autocomplete="current-password">
```

## Styling

Password input styling is provided by `castd.css`.

### States

- `:focus` — Focus ring
- `:disabled` — Reduced opacity
- `:invalid` — Error styling
- `:valid` — Success styling

## Autocomplete Values

| Value | Use Case |
|-------|----------|
| `current-password` | Login forms (default) |
| `new-password` | Registration/change password |
| `off` | Disable autocomplete |

## Examples

### Login Form

```html
{( cn:preset.form.input label="Email" type="email" name="email" autocomplete="email" required=true )}
{( cn:preset.form.password label="Password" name="password" required=true )}
```

### Registration Form

```html
{( cn:preset.form.password 
    label="Create password" 
    name="password" 
    autocomplete="new-password" 
    minlength="8" 
    required=true 
)}
{( cn:preset.form.password 
    label="Confirm password" 
    name="password_confirm" 
    autocomplete="new-password" 
    minlength="8" 
    required=true 
)}
```

### With Minimum Length

```html
{( cn:preset.form.password 
    label="Password" 
    name="password" 
    minlength="12" 
    placeholder="At least 12 characters" 
    required=true 
)}
```

## Password Toggle

To add a show/hide toggle:

```html
<div class="password-field">
    {( cn:preset.form.password label="Password" name="password" id="pwd" )}
    <button type="button" onclick="togglePassword()">Show</button>
</div>

<script>
function togglePassword() {
    const input = document.getElementById('pwd');
    const btn = event.target;
    if (input.type === 'password') {
        input.type = 'text';
        btn.textContent = 'Hide';
    } else {
        input.type = 'password';
        btn.textContent = 'Show';
    }
}
</script>
```

## Validation

For password strength validation:

```javascript
const password = document.querySelector('input[name="password"]');

password.addEventListener('input', () => {
    const value = password.value;
    const hasLower = /[a-z]/.test(value);
    const hasUpper = /[A-Z]/.test(value);
    const hasNumber = /[0-9]/.test(value);
    const hasSpecial = /[^a-zA-Z0-9]/.test(value);
    const isLong = value.length >= 12;
    
    // Update strength indicator
    const strength = [hasLower, hasUpper, hasNumber, hasSpecial, isLong].filter(Boolean).length;
});
```

## See Also

- [cn:preset.form.input](input.md) — General text input

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
