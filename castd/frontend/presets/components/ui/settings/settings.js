// Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
// SPDX-License-Identifier: Apache-2.0

// cn.ui.settings — Settings wizard component logic
// 'this' refers to the <dialog> element

const dialog = this;
const wizardEl = dialog.querySelector(".as-wizard");
if (!wizardEl) return;

// Configuration from data attributes
const config = {
  cookieName: dialog.dataset.cookieName || "cn_prefs",
  cookieDays: parseInt(dialog.dataset.cookieDays, 10) || 365,
  cookiesApi: dialog.dataset.cookiesApi || null,
  fontSizes: { sm: "14px", md: "16px", lg: "18px" },
};

// Cache wizard section for language switching (before i18n.apply removes data-ml)
if (typeof cn !== "undefined" && cn.i18n?.cache) {
  cn.i18n.cache(`#${dialog.id} > .as-wizard > section`);
}

// Cookie helpers
const getPrefs = () => {
  const cookie = document.cookie
    .split("; ")
    .find((c) => c.startsWith(config.cookieName + "="));
  if (!cookie) return null;
  try {
    return JSON.parse(decodeURIComponent(cookie.split("=")[1]));
  } catch {
    return null;
  }
};

const setPrefs = (prefs) => {
  const expires = new Date(
    Date.now() + config.cookieDays * 864e5,
  ).toUTCString();
  document.cookie = `${config.cookieName}=${encodeURIComponent(JSON.stringify(prefs))};expires=${expires};path=/;SameSite=Strict`;
};

// Theme helpers
const getSystemTheme = () =>
  matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";

const applyPrefs = (prefs) => {
  const html = document.documentElement;
  html.style.colorScheme = prefs?.theme || getSystemTheme();
  if (config.fontSizes[prefs?.fontSize]) {
    html.style.fontSize = config.fontSizes[prefs.fontSize];
  }
};

// Load preferences into dialog form elements
const loadPrefsIntoDialog = (prefs) => {
  const analytics = dialog.querySelector('[name="cookies-analytics"]');
  const marketing = dialog.querySelector('[name="cookies-marketing"]');
  const darkToggle = dialog.querySelector('[name="theme-dark"]');
  const langSelect = dialog.querySelector('[name="language"]');
  const emailNotify = dialog.querySelector('[name="notify-email"]');
  const pushNotify = dialog.querySelector('[name="notify-push"]');

  if (analytics) analytics.checked = prefs?.cookies?.analytics || false;
  if (marketing) marketing.checked = prefs?.cookies?.marketing || false;

  // Dark mode: use saved pref, or current colorScheme, or system preference
  if (darkToggle) {
    const currentScheme = document.documentElement.style.colorScheme;
    const effectiveTheme = prefs?.theme || currentScheme || getSystemTheme();
    darkToggle.checked = effectiveTheme === "dark";
  }

  // Font size
  const fsRadio = dialog.querySelector(
    `[name="fontsize"][value="${prefs?.fontSize || "md"}"]`,
  );
  if (fsRadio) fsRadio.checked = true;

  // Language
  if (langSelect) {
    langSelect.value = prefs?.lang || document.documentElement.lang || "en-GB";
  }

  // Notifications
  if (emailNotify) emailNotify.checked = prefs?.notifications?.email || false;
  if (pushNotify) pushNotify.checked = prefs?.notifications?.push || false;
};

// Save preferences from dialog form elements
const savePrefsFromDialog = async () => {
  const newLang =
    dialog.querySelector('[name="language"]')?.value ||
    document.documentElement.lang ||
    "en-GB";
  const prefs = {
    cookies: {
      essential: true,
      analytics:
        dialog.querySelector('[name="cookies-analytics"]')?.checked || false,
      marketing:
        dialog.querySelector('[name="cookies-marketing"]')?.checked || false,
    },
    theme: dialog.querySelector('[name="theme-dark"]')?.checked
      ? "dark"
      : "light",
    fontSize: dialog.querySelector('[name="fontsize"]:checked')?.value || "md",
    lang: newLang,
    notifications: {
      email: dialog.querySelector('[name="notify-email"]')?.checked || false,
      push: dialog.querySelector('[name="notify-push"]')?.checked || false,
    },
  };

  setPrefs(prefs);
  applyPrefs(prefs);

  // Send cookie consent to API if configured
  if (config.cookiesApi) {
    try {
      await fetch(config.cookiesApi, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(prefs.cookies),
      });
    } catch (err) {
      console.warn("Failed to send cookie consent to API:", err);
    }
  }

  // Switch language and re-apply translations
  if (typeof cn !== "undefined" && cn.i18n?.switchLang) {
    localStorage.setItem("cn-lang", newLang);
    cn.i18n.switchLang(newLang);
  }

  // Dispatch custom event for external listeners
  dialog.dispatchEvent(
    new CustomEvent("cn:settings-saved", {
      bubbles: true,
      detail: { prefs },
    }),
  );

  return prefs;
};

// Initialise live option switching in the dialog
const initLiveOptions = () => {
  const darkToggle = dialog.querySelector('[name="theme-dark"]');
  if (darkToggle && !darkToggle._cnInit) {
    darkToggle._cnInit = true;
    darkToggle.onchange = () => {
      document.documentElement.style.colorScheme = darkToggle.checked
        ? "dark"
        : "light";
    };
  }

  dialog.querySelectorAll('[name="fontsize"]').forEach((radio) => {
    if (radio._cnInit) return;
    radio._cnInit = true;
    radio.onchange = () => {
      document.documentElement.style.fontSize =
        config.fontSizes[radio.value] || "16px";
      // Refresh wizard step to recalculate height
      requestAnimationFrame(() => {
        const wizard = cn?.wizard?.get(`#${wizardEl.id}`);
        if (wizard) {
          const step = wizard.getStep();
          wizard.goToStep(step);
        }
      });
    };
  });
};

// Open dialog function
const openDialog = () => {
  loadPrefsIntoDialog(getPrefs());
  initLiveOptions();
  dialog.showModal();
};

// Handle wizard save event
document.addEventListener("cn:wizard-save", (e) => {
  if (e.target === wizardEl || wizardEl.contains(e.target)) {
    savePrefsFromDialog();
    dialog.close();
  }
});

// Close button handling
dialog.querySelectorAll("[data-close]").forEach((btn) => {
  btn.onclick = () => dialog.close();
});

// Apply saved preferences on load
const savedPrefs = getPrefs();
if (savedPrefs) {
  applyPrefs(savedPrefs);
  if (savedPrefs.lang) {
    document.documentElement.lang = savedPrefs.lang;
    if (typeof cn !== "undefined" && cn.i18n?.lang) {
      cn.i18n.lang(savedPrefs.lang);
    }
  }
}

// Expose API on the dialog element
dialog.cnSettings = {
  open: openDialog,
  getPrefs,
  setPrefs,
  applyPrefs,
  save: savePrefsFromDialog,
};

// Also expose globally for convenience
window.cnSettings = window.cnSettings || {};
window.cnSettings[dialog.id] = dialog.cnSettings;
