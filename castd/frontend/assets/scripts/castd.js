// Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
// SPDX-License-Identifier: Apache-2.0

// castd.js — Minimal client-side core
// Data-Bus, i18n, Preferences, Theme

// Data-Bus: Centralised state management
// Usage: cm.get("i18n.lang"), cm.set("prefs.theme", "dark")
const data = (() => {
  const store = {
    i18n: {
      page: {},
      lang: document.documentElement.lang || "en-GB",
    },
    prefs: {
      theme: null,
      lang: null,
    },
  };

  const resolvePath = (path) => {
    const parts = path.split(".");
    let obj = store;
    for (let i = 0; i < parts.length - 1; i++) {
      if (obj[parts[i]] === undefined) return { obj: null, key: null };
      obj = obj[parts[i]];
    }
    return { obj, key: parts[parts.length - 1] };
  };

  const get = (path) => {
    const { obj, key } = resolvePath(path);
    return obj?.[key];
  };

  const set = (path, value) => {
    const { obj, key } = resolvePath(path);
    if (obj && key) obj[key] = value;
    return value;
  };

  return { store, get, set };
})();

// i18n: Runtime language switching
// Usage: cm.i18n.load("index.csv"), cm.i18n.t("key"), cm.i18n.switchLang("de-DE")
const i18n = (() => {
  const store = data.store.i18n;

  const lang = (val) => {
    if (val !== undefined) {
      store.lang = val;
      document.documentElement.lang = val;
    }
    return store.lang;
  };

  const parseCSV = (csv) => {
    const result = {};
    csv.split("\n").forEach((line) => {
      const [key, value, l] = line.split(";").map((s) => s?.trim());
      if (key && value && l) {
        if (!result[l]) result[l] = {};
        result[l][key] = value;
      }
    });
    return result;
  };

  const t = (key) => {
    const l = lang();
    if (store.page[l]?.[key]) return store.page[l][key];
    if (store.page["en-GB"]?.[key]) return store.page["en-GB"][key];
    return key;
  };

  const load = (src) =>
    fetch(src)
      .then((r) => r.text())
      .then((csv) => {
        store.page = parseCSV(csv);
        return i18n;
      });

  const apply = (root = document) => {
    root.querySelectorAll("[data-ml]").forEach((el) => {
      const key = el.dataset.ml;
      const val = t(key);
      if (val !== key) {
        el.textContent = val;
        el.removeAttribute("data-ml");
      }
    });
  };

  const switchLang = (newLang) => {
    lang(newLang);
    localStorage.setItem("cm-lang", newLang);
    location.reload();
  };

  const init = () => {
    const saved = localStorage.getItem("cm-lang");
    if (saved) lang(saved);
  };

  return { lang, t, load, apply, switchLang, init };
})();

// Preferences: localStorage-backed settings
// Usage: cm.prefs.set("theme", "dark"), cm.prefs.get("theme")
const prefs = (() => {
  const PREFIX = "cm-";

  const get = (key) => {
    const val = localStorage.getItem(PREFIX + key);
    return val ? JSON.parse(val) : null;
  };

  const set = (key, value) => {
    localStorage.setItem(PREFIX + key, JSON.stringify(value));
    data.set(`prefs.${key}`, value);
    return value;
  };

  const remove = (key) => {
    localStorage.removeItem(PREFIX + key);
    data.set(`prefs.${key}`, null);
  };

  const init = () => {
    ["theme", "lang"].forEach((key) => {
      const val = get(key);
      if (val) data.set(`prefs.${key}`, val);
    });
  };

  return { get, set, remove, init };
})();

// Theme: Toggle dark/light mode
// Usage: cm.theme.toggle(), cm.theme.set("dark"), cm.theme.get()
const theme = (() => {
  const ATTR = "data-theme";

  const get = () => document.documentElement.getAttribute(ATTR) || "light";

  const set = (value) => {
    document.documentElement.setAttribute(ATTR, value);
    prefs.set("theme", value);
    return value;
  };

  const toggle = () => set(get() === "dark" ? "light" : "dark");

  const init = () => {
    const saved = prefs.get("theme");
    if (saved) {
      document.documentElement.setAttribute(ATTR, saved);
    }
  };

  return { get, set, toggle, init };
})();

// Code: Transform pre>code blocks for line numbers and hover
// Usage: cm.code.init() — auto-runs on DOMContentLoaded
const code = (() => {
  const init = (root = document) => {
    root.querySelectorAll("pre > code").forEach((codeEl) => {
      if (codeEl.querySelector("[data-line]")) return;
      const lines = codeEl.textContent.split("\n");
      if (lines[lines.length - 1] === "") lines.pop();
      codeEl.innerHTML = lines
        .map((line) => `<span data-line>${escapeHtml(line) || " "}</span>`)
        .join("\n");
    });
  };

  const escapeHtml = (str) =>
    str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");

  return { init };
})();

// Namespace
window.cm = window.cm || {};
cm.data = data;
cm.i18n = i18n;
cm.prefs = prefs;
cm.theme = theme;
cm.code = code;
cm.get = data.get;
cm.set = data.set;

// Auto-init
prefs.init();
theme.init();
i18n.init();
document.addEventListener("DOMContentLoaded", () => code.init());
