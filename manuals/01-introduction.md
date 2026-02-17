# Introduction

Frameworks have bloated IT infrastructure for years — often without good reason.

---

## What is CASTD?

**CASTD — Stackless webserver.**

Your entire web stack in one binary. No Nginx, no PHP, no MySQL — one
process that serves HTTP, renders templates, and stores data.

| Component | Purpose |
|-----------|---------|
| **HTTP Server** | Serves pages directly — no reverse proxy required |
| **CAST** | Template language (Content & Structure Templating) |
| **SQLite** | Built-in database — no setup, no credentials |
| **CSS Framework** | Styling without build tools |
| **Presets** | Reusable components |
| **Lua Extensions** | Custom business logic, sandboxed |

No separate backend. No API layer. No build pipeline. Templates access the database directly, components include themselves, the server delivers HTML.

---

## Your Entire Stack in One Binary

A traditional web server stack — LEMP (Linux, Nginx, MySQL, PHP) or FEMP
(FreeBSD, Nginx, MySQL, PHP) — is four separate systems bolted together:

| LEMP Component | CASTD Equivalent |
|----------------|------------------|
| Nginx | Built-in HTTP server |
| MySQL | SQLite, compiled into the binary |
| PHP | CAST (Content & Structure Templating) |
| Linux/FreeBSD | Runs on both, plus macOS |

CASTD is the evolutionary minimisation of this stack. Four packages become
one binary. This is not merely convenient — it is a fundamental reduction
of attack surface and operational risk.

### Every Interface Is a Risk

Each connection between components in a traditional stack is an attack
vector, a configuration burden, and a source of failure:

| Interface | Risk |
|-----------|------|
| Nginx ↔ PHP (FastCGI) | Socket misconfiguration, timeout mismatches, request smuggling |
| PHP ↔ MySQL (TCP/Socket) | Credentials in plaintext config files, network-exposed database port |
| MySQL ↔ Disk | User privilege escalation, remote access, replication vulnerabilities |
| Nginx ↔ Client | Separate hardening, its own CVE history |

**CASTD has zero internal interfaces.** There is no IPC between server and
language. There is no network connection to the database. There is no
credential file. Everything is a function call within a single process:

- **SQLite is in-process** — no TCP port, no password, no network exposure
- **CAST is the parser** — no separate interpreter, no `eval()`, no code injection
- **The HTTP server is the application** — no proxy layer required

Fewer moving parts. Fewer configuration files. Fewer CVEs. Faster.

### Two Languages, Clear Separation

CASTD provides two languages with distinct roles:

| Language | Role | Scope |
|----------|------|-------|
| **CAST** | Control language | Templates — data, logic, components, persistence |
| **Lua** | Extension language | Server-side modules — routes, APIs, helpers |

CAST is not a programming language. It is a declarative template syntax
with five delimiters. You cannot write arbitrary logic in CAST — you
declare what data to fetch, what conditions to check, and what components
to render. This constraint is intentional: it makes CAST injection
architecturally impossible.

Lua handles everything that exceeds declarative templating: custom business
logic, external API calls, data transformations. Extensions run in a
sandboxed environment with controlled access to the `cn.*` API. They
cannot access the filesystem, execute system commands, or bypass the
security model.

### What This Means in Practice

| Metric | LEMP/FEMP Stack | CASTD |
|--------|-----------------|-------|
| Components to install | 4+ | 1 |
| Configuration files | 4+ (nginx.conf, php.ini, my.cnf, pool.d/) | 1 (server.toml, optional) |
| Ports to secure | 2+ (80/443, 3306) | 1 (HTTP or Unix socket) |
| Credential files | 2+ (database, FTP) | 0 |
| Processes to monitor | 4+ (nginx, php-fpm, mysqld, cron) | 1 |
| Update surface | 4 independent release cycles | 1 binary |
| Version mismatches | Common (PHP 8.1 vs extension for 7.4) | Impossible |
| CVE monitoring | 4 separate advisories | 1 |

---

## The Cost of Modern Web Development

A simple content website — blog, shop, company page. Here's what frameworks have turned this into:

### The Chain of Complexity

| Stage | Framework Approach | CASTD |
|-------|-------------------|------------|
| **Learning** | Weeks to months (React hooks, state management, build tools) | Hours (5 delimiters, HTML knowledge sufficient) |
| **Development** | 3 specialists (Frontend, Backend, DevOps) | 1 developer |
| **Dependencies** | 1,500+ npm packages | 0 client dependencies |
| **Build** | Webpack/Vite config, transpilation, bundling | None |
| **Testing** | Unit tests, integration tests, E2E, hydration edge cases | HTML output — what you see is what you test |
| **Security Audit** | 1,500+ packages to review per update | 1 binary |
| **Deployment** | Container orchestration, Node.js runtime, build pipelines | Single binary, copy and run |
| **Infrastructure** | Node servers, build servers, CDN for bundles | One server |
| **Debugging** | React DevTools, state inspection, render cycle analysis | View source |

### Example Calculation: Corporate Website

**Assumptions:** Company website with blog, contact form, product pages. 50 pages, moderate traffic.

#### Framework Approach (React/Next.js)

| Role | Headcount | Reason |
|------|-----------|--------|
| Frontend | 2 | No knowledge silos |
| Backend | 2 | No knowledge silos |
| DevOps | 2 | No knowledge silos |
| **Total** | **6 FTE** | |

This separation is artificial. Until ten years ago, the role was simply called "Web Developer" — one person who built websites. Most backend developers can write frontend code and vice versa. But framework complexity forces specialisation: React hooks require different expertise than Express middleware, which differs from Kubernetes configuration. The tools demand specialists — not the work itself.

| Item | Cost Factor |
|------|-------------|
| **Development Time** | 3 months |
| **Onboarding** | 2-4 weeks per developer |
| **Infrastructure** | Node.js servers, build pipeline, CDN |
| **Monthly Maintenance** | Dependency updates, security patches, Node version upgrades |
| **Security Audits** | Quarterly review of dependency tree |
| **Incident Rate** | "It worked yesterday" — hydration, state, build cache |

**Estimated Annual Cost (Team only):** 6 × €70,000 = **€420,000**

#### CASTD Approach

| Role | Headcount | Reason |
|------|-----------|--------|
| Webstack Developer | 2 | No knowledge silos |
| **Total** | **2 FTE** | |

A Webstack Developer builds the entire site — templates, database access, deployment — with one system. HTML knowledge required. Backend or DevOps experience not needed. CAST handles data access declaratively, the server is a single binary.

In the age of AI pair programming, this matters even more. The simpler the syntax, the fewer mistakes AI makes. The smaller the codebase, the faster a developer can review AI-generated code. CAST's minimal syntax — five delimiters, no framework magic — means AI suggestions are predictable and easy to verify. A developer can review ten lines of CAST in seconds. Reviewing ten lines of React with hooks, context, and effects takes minutes — and might still hide bugs.

| Item | Cost Factor |
|------|-------------|
| **Development Time** | 1 month |
| **Onboarding** | 1-2 days |
| **Infrastructure** | One server, static files |
| **Monthly Maintenance** | Minimal — no dependency tree |
| **Security Audits** | One binary, predictable surface |
| **Incident Rate** | HTML renders or it doesn't — no hidden state |

**Estimated Annual Cost (Team only):** 2 × €70,000 = **€140,000**

#### The Difference

| Metric | Factor |
|--------|--------|
| Team size | **3× smaller** (6 → 2) |
| Time to market | **3× faster** |
| Onboarding | **10× faster** |
| Dependencies to audit | **1,500× fewer** |
| Infrastructure complexity | **5× simpler** |
| Annual team cost | **3× lower** (€420k → €140k) |
| **Savings per year** | **€280,000** |

Now extrapolate to your department size.

**Example:** A mid-sized company with 20 developers and 10 DevOps engineers.

| | Framework | CASTD |
|--|-----------|------------|
| Developers | 20 | 10 |
| DevOps | 10 | 0 |
| **Total** | 30 | 10 |
| **Annual cost** | €2,100,000 | €700,000 |
| **Savings** | | **€1,400,000/year** |

The savings scale linearly. The complexity reduction scales better — fewer people means fewer handoffs, fewer meetings, fewer misunderstandings.

A CASTD support plan costs roughly €0.003 per visitor per year. A site with 1 million annual visitors: €3,000 for professional support. Compare that to €1,400,000 in staff costs.

---

## What CASTD Actually Does

One server. HTML templates. Database access. Done.

### Five Delimiters

```
{{ }}   Data output
{! !}   Logic (if, each)
{( )}   Components
{* *}   Database operations
{# #}   Comments
```

That's the entire syntax.

### A Complete Page

```html
{* read db.posts | where published=true | order=created desc | limit=10 *}
  {! each items !}
    <article>
      <h2>{{ item.title }}</h2>
      <p>{{ item.excerpt }}</p>
      <a href="/posts/{{ item.slug }}">Read more</a>
    </article>
  {! endeach !}
{* endread *}
```

No API layer. No state management. No build step. The server reads from the database, loops, outputs HTML.

### Components Without Configuration

```html
{( cn:preset.ui.card[title="Welcome"] )}
{( cn:preset.form.button["Submit"] | action="/api/save" )}
```

CSS and JavaScript collected automatically. No imports, no bundler configuration.

### Reactivity When You Need It

Most content is static. For the parts that aren't:

```html
{! api stock_feed | websocket !}{! endapi !}

{! bind product.stock !}
  <span>{{ product.stock }} in stock</span>
{! endbind !}
```

Reactive islands in static HTML. You declare where live updates happen — the rest stays simple.

---

## Security by Architecture

| Attack Vector | Framework | CASTD |
|---------------|-----------|------------|
| XSS | Opt-out (`v-html`, `dangerouslySetInnerHTML`) | Opt-in (`\| raw`) |
| Supply Chain | 1,500+ npm packages | 0 client dependencies |
| API Exposure | Endpoints visible in DevTools | No client-visible APIs |
| Prototype Pollution | Possible via dependencies | No JavaScript objects from dependencies |

**Default behaviour:** Everything escaped. No exposed endpoints. No foreign code in the browser.

---

## Honest Limitations

CASTD is not for everything.

**Don't use it for:**
- Figma-level interactivity
- Offline-first applications
- Real-time collaborative editing
- Complex client-side state

**Do use it for:**
- Marketing sites
- Blogs, news, content platforms
- E-commerce
- Admin panels
- Anything where users mostly read

If your users mostly read and occasionally click, you don't need a reactive framework. You need a server that renders HTML well.

---

## Getting Started

1. **[Getting Started](02-getting-started.md)** — Installation, configuration, first bundle, updates
2. **[Concepts](03-concepts.md)** — Design principles
3. **[CAST Reference](05-cast-reference.md)** — Template syntax
4. **[Styling](07-styling.md)** — CSS framework
5. **[Presets](10-presets.md)** — Components

No npm install. No build tools. Clone, configure, run.

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
