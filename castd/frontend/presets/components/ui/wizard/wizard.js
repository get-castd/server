// Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
// SPDX-License-Identifier: Apache-2.0

// cm.ui.wizard — Multi-step wizard logic
// Automatically initialises all .as-wizard elements

(function() {
    const instances = new Map();

    const init = (el) => {
        if (instances.has(el)) return instances.get(el);

        const section = el.querySelector(":scope > section");
        if (!section) return null;

        const steps = Array.from(section.children);
        if (steps.length === 0) return null;

        let currentStep = 0;
        const continueText = el.dataset.cmContinue || "Continue";
        const saveText = el.dataset.cmSave || "Save";

        // Create footer with dots and button
        const footer = document.createElement("footer");

        // Create navigation dots
        const nav = document.createElement("nav");
        nav.setAttribute("aria-label", "Wizard steps");

        steps.forEach((_, i) => {
            const dot = document.createElement("button");
            dot.type = "button";
            dot.setAttribute("aria-label", `Step ${i + 1}`);
            dot.setAttribute("aria-selected", i === 0 ? "true" : "false");
            dot.onclick = () => goToStep(i);
            nav.appendChild(dot);
        });

        // Create action button
        const actionBtn = document.createElement("button");
        actionBtn.type = "button";
        actionBtn.textContent = steps.length > 1 ? continueText : saveText;
        actionBtn.onclick = () => {
            if (currentStep < steps.length - 1) {
                goToStep(currentStep + 1);
            } else {
                el.dispatchEvent(new CustomEvent("cm:wizard-save", { bubbles: true }));
            }
        };

        footer.appendChild(nav);
        footer.appendChild(actionBtn);
        el.appendChild(footer);

        // Set initial inert state
        steps.forEach((step, i) => {
            if (i !== 0) step.setAttribute("inert", "");
        });

        const goToStep = (index) => {
            if (index < 0 || index >= steps.length) return;

            // Update inert states
            steps[currentStep].setAttribute("inert", "");
            steps[index].removeAttribute("inert");

            // Update transform
            section.style.transform = `translateX(-${index * 100}%)`;

            // Update dots
            const dots = nav.querySelectorAll("button");
            dots[currentStep].setAttribute("aria-selected", "false");
            dots[index].setAttribute("aria-selected", "true");

            // Update button text
            actionBtn.textContent = index === steps.length - 1 ? saveText : continueText;

            currentStep = index;
        };

        const api = {
            goToStep,
            getStep: () => currentStep,
            next: () => goToStep(currentStep + 1),
            prev: () => goToStep(currentStep - 1),
            element: el
        };

        instances.set(el, api);
        return api;
    };

    // Auto-init all wizards on DOMContentLoaded
    const initAll = () => {
        document.querySelectorAll(".as-wizard").forEach(init);
    };

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initAll);
    } else {
        initAll();
    }

    // Expose API
    window.cm = window.cm || {};
    cm.wizard = {
        init,
        get: (selector) => {
            const el = typeof selector === "string" ? document.querySelector(selector) : selector;
            return el ? instances.get(el) || init(el) : null;
        },
        getAll: () => Array.from(instances.values())
    };
})();
