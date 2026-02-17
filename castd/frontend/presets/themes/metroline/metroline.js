// Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
// SPDX-License-Identifier: Apache-2.0

// metroline.js — Metroline theme enhancements

// Code blocks: Wrap lines in <span data-line> for line numbers
document.querySelectorAll("pre > code").forEach((code) => {
    if (code.querySelector("[data-line]")) return;

    const lines = code.textContent.split("\n");
    if (lines[lines.length - 1] === "") lines.pop();

    code.textContent = "";
    lines.forEach((line) => {
        const span = document.createElement("span");
        span.setAttribute("data-line", "");
        span.textContent = line || " ";
        code.appendChild(span);
        code.appendChild(document.createTextNode("\n"));
    });
});
