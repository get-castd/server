# Business Model

> CASTD is fully open source under Apache 2.0. Source code is included in
> every distribution. Revenue comes from the optional Admin Center add-on.

This document explains how CASTD sustains itself commercially whilst
remaining genuinely useful to developers who never pay a penny.

---

## Product

CASTD is a single product. The `castd.css` stylesheet can also be used
standalone without the server.

### What Ships

- `castd.css` — Complete styling system (also usable standalone)
- `castd.js` — Client utilities (Data-Bus, i18n, Preferences, Theme)
- Presets as HTML/CSS reference (copy-paste usage)
- CAST template language
- Persistence layer (database, authentication, volumes)
- Lua extensions for business logic
- Server binary for Linux, macOS, FreeBSD
- Complete source code as `src.tar.xz`

**Licence:** Apache 2.0
**Cost:** Free
**Source:** Included

---

## Revenue Model

### Admin Center (Paid Add-on)

A graphical interface for content editors, inspired by Craft CMS.

| Aspect | Description |
|--------|-------------|
| **Purpose** | Allow non-technical editors to manage content |
| **Target** | Agencies, teams with dedicated editors, clients |
| **Scope** | Server add-on — extends CASTD |
| **Licence** | Proprietary, per-site |
| **Pricing** | Per-site licence (one-time or subscription, TBD) |

**What it provides:**

- Visual content editing without touching templates
- Media library with focal point selection
- User management with role-based access
- Entry versioning and drafts
- Preview before publish

**What it does not provide:**

- Template editing (that remains in code)
- Server configuration (that remains in `server.toml`)
- Anything a developer wouldn't want an editor touching

**Design principle:** The Admin Center is for editors, not developers. It
presents exactly what an editor needs and nothing more. No WordPress-style
settings pages, no plugin marketplaces, no visual page builders.

---

## Why This Model Works

### For Developers

CASTD is not a demo or a stripped-down community edition. It is the
complete product. A solo developer can build and deploy a full application
without ever encountering a paywall.

This matters because:

1. **Trust** — Developers evaluate tools before recommending them to clients
2. **Adoption** — No friction means more projects use CASTD
3. **Community** — Contributors emerge from users, not customers

### For Agencies

Agencies work with clients who have ongoing content needs. These clients
rarely want to edit HTML templates. They want:

- A familiar interface (like WordPress, but cleaner)
- The ability to update text and images themselves
- Confidence they cannot break the site

The Admin Center serves this need. It justifies its cost by reducing the
agency's support burden and improving client satisfaction.

### For Min2Max

Revenue from Admin Center licences funds continued development of the
open-source core. This creates a sustainable cycle:

```
Free framework → Developer adoption → Agency projects → Admin Centre sales
       ↑                                                        │
       └────────────────────────────────────────────────────────┘
                        Funds development
```

---

## Architecture: LEAT

CASTD is built on the **LEAT** pattern (Linear Event-Actor-Turnback),
which reflects how the web actually works:

| Step | Description |
|------|-------------|
| **Event** | Request arrives (HTTP, WebSocket, form) |
| **Actor** | Handler processes (render, query, logic) |
| **Turnback** | Response returns (HTML, JSON, redirect) |

This linear flow differs from desktop MVC, where components observe each
other in memory. On the web, nothing persists between requests — LEAT
embraces this rather than pretending otherwise.

**Benefits:**

- **Simplicity** — Each request is a straight line, not a graph
- **Testability** — Small, focused functions without circular dependencies
- **Performance** — No framework overhead maintaining phantom state

---

## Comparison with Alternatives

| Aspect | WordPress | Craft CMS | CASTD |
|--------|-----------|-----------|-------|
| Core licence | GPL (free) | MIT (free) | Apache 2.0 (free) |
| Source included | Yes | Yes | Yes |
| Admin interface | Bundled | Bundled | Separate (paid) |
| Editor experience | Complex | Excellent | Excellent (with Admin Centre) |
| Developer experience | Plugin-dependent | Good | Excellent |
| Architecture | MVC-ish | MVC | LEAT |
| Self-hosted | Yes | Yes | Yes |
| Performance | Variable | Good | Excellent |
| Footprint | Heavy | Medium | Minimal |

**Key difference:** Craft CMS bundles its admin interface and charges for
Pro features (user permissions, GraphQL). CASTD separates the admin
interface entirely — developers get the full technical stack for free,
and only pay if they need editor tooling.

---

## Pricing Philosophy

Pricing details are not finalised, but the principles are:

1. **Per-site, not per-seat** — A licence covers one production domain
2. **No runtime restrictions** — The Admin Centre runs locally without phoning home
3. **Perpetual option** — One-time purchase includes updates for that major version
4. **Subscription option** — Ongoing updates across major versions

**Anti-patterns we avoid:**

- Usage-based pricing (unpredictable costs)
- Required accounts or activation servers
- Feature degradation after trial expiry
- Upselling within the interface

---

## Roadmap

| Phase | Focus |
|-------|-------|
| **Current** | Framework stability, documentation, community adoption |
| **Next** | Admin Centre development (private alpha) |
| **Future** | Admin Centre public release, enterprise features |

Enterprise features (SSO, audit logging, multi-site management) will follow
the same model: optional add-ons that extend the free core.

---

## Transparency

This document is public. We believe developers should understand how the
tools they use sustain themselves. Hidden monetisation (telemetry, data
collection, VC-funded growth-at-all-costs) erodes trust.

CASTD is built by Min2Max, a small company that values sustainability
over scale. We would rather have a modest, profitable product than a
large, precarious one.

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
