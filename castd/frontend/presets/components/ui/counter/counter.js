// Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
// SPDX-License-Identifier: Apache-2.0

// cm.ui.counter — Counter behaviour
document.querySelectorAll('.as-counter').forEach(counter => {
    const input = counter.querySelector('input[type="number"]');
    const decrement = counter.querySelector('.counter-decrement');
    const increment = counter.querySelector('.counter-increment');

    if (!input || !decrement || !increment) return;

    const min = input.min !== '' ? parseFloat(input.min) : -Infinity;
    const max = input.max !== '' ? parseFloat(input.max) : Infinity;
    const step = parseFloat(input.step) || 1;

    function updateValue(delta) {
        let value = parseFloat(input.value) || 0;
        value = Math.max(min, Math.min(max, value + delta));
        input.value = value;
        input.dispatchEvent(new Event('change', { bubbles: true }));
    }

    decrement.addEventListener('click', () => updateValue(-step));
    increment.addEventListener('click', () => updateValue(step));
});
