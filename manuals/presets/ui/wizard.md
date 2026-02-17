# cn:preset.ui.wizard

Multi-step form wizard.

## Usage

```html
{( cn:preset.ui.wizard content="
    <section data-step='1'>
        <h3>Step 1: Account</h3>
        <p>Enter your details</p>
    </section>
    <section data-step='2'>
        <h3>Step 2: Preferences</h3>
        <p>Set your preferences</p>
    </section>
    <section data-step='3'>
        <h3>Step 3: Confirm</h3>
        <p>Review and submit</p>
    </section>
" )}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | **Required** | Step sections (supports HTML) |
| `continue` | string | — | Continue button selector (`data-cn-continue`) |
| `save` | string | — | Save progress URL (`data-cn-save`) |
| `style` | string | — | Inline CSS styles |

## Output

```html
<div class="as-wizard" data-cn-continue=".next-btn" data-cn-save="/api/save">
    <section>
        <section data-step="1">
            <h3>Step 1: Account</h3>
            <p>Enter your details</p>
        </section>
        ...
    </section>
</div>
```

## Styling

Wizard styling is provided by `castd.css`. Only the active step is visible.

## Examples

### Registration Wizard

```html
{( cn:preset.ui.wizard content="
    <section data-step='1'>
        <h3>Create Account</h3>
        {( cn:preset.form.input label='Email' type='email' name='email' required=true )}
        {( cn:preset.form.password label='Password' name='password' required=true )}
        <button class='next-btn'>Continue</button>
    </section>
    <section data-step='2'>
        <h3>Personal Details</h3>
        {( cn:preset.form.input label='Name' name='name' )}
        {( cn:preset.form.input label='Company' name='company' )}
        <button class='prev-btn'>Back</button>
        <button class='next-btn'>Continue</button>
    </section>
    <section data-step='3'>
        <h3>Confirm</h3>
        <p>Please review your information.</p>
        <button class='prev-btn'>Back</button>
        <button type='submit'>Create Account</button>
    </section>
" continue=".next-btn" )}
```

### Checkout Wizard

```html
{( cn:preset.ui.wizard content="
    <section data-step='1'>
        <h3>Shipping</h3>
        <!-- Address fields -->
    </section>
    <section data-step='2'>
        <h3>Payment</h3>
        <!-- Payment fields -->
    </section>
    <section data-step='3'>
        <h3>Review Order</h3>
        <!-- Order summary -->
    </section>
" save="/api/checkout/save" )}
```

## JavaScript Integration

Basic wizard navigation:

```javascript
class Wizard {
    constructor(element) {
        this.el = element;
        this.steps = element.querySelectorAll('[data-step]');
        this.current = 0;
        this.init();
    }
    
    init() {
        this.showStep(0);
        this.el.querySelectorAll('.next-btn').forEach(btn => {
            btn.addEventListener('click', () => this.next());
        });
        this.el.querySelectorAll('.prev-btn').forEach(btn => {
            btn.addEventListener('click', () => this.prev());
        });
    }
    
    showStep(index) {
        this.steps.forEach((step, i) => {
            step.hidden = i !== index;
        });
        this.current = index;
    }
    
    next() {
        if (this.current < this.steps.length - 1) {
            this.showStep(this.current + 1);
        }
    }
    
    prev() {
        if (this.current > 0) {
            this.showStep(this.current - 1);
        }
    }
}

document.querySelectorAll('.as-wizard').forEach(el => new Wizard(el));
```

## Progress Indicator

Add a visual progress indicator:

```html
<div class="wizard-progress">
    <span class="is-active">1. Account</span>
    <span>2. Details</span>
    <span>3. Confirm</span>
</div>
```

## Validation

Validate each step before proceeding:

```javascript
next() {
    const currentStep = this.steps[this.current];
    const inputs = currentStep.querySelectorAll('input, select, textarea');
    const valid = Array.from(inputs).every(input => input.checkValidity());
    
    if (valid && this.current < this.steps.length - 1) {
        this.showStep(this.current + 1);
    }
}
```

## See Also

- [cn:preset.ui.tabs](tabs.md) — Tab navigation
- [cn:preset.form.button](../form/button.md) — Navigation buttons

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*  
*SPDX-License-Identifier: Apache-2.0*
