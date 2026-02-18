# Getting Started

> From clone to running site in five minutes. No npm. No build tools.
> One binary, your templates, done.

This guide covers the complete lifecycle: installation, configuration,
creating your first bundle, keeping the framework up to date, and deploying
to production.

---

## Installation

Clone the distribution repository as your project:

```bash
git clone git@gitlab.com:min2max/castd/server.git my-project
cd my-project
```

Rename the remote. `upstream` becomes your source for framework updates.
Add your own repository as `origin`:

```bash
git remote rename origin upstream
git remote add origin git@your-server.com:your-org/my-project.git
git push -u origin main
```

You now have two remotes:

| Remote | Purpose | You push? |
|--------|---------|-----------|
| `origin` | Your project repository | Yes |
| `upstream` | Framework updates | Never |

### What You Get

```
my-project/
├── castd/                  # Framework — do not modify
│   ├── backend/
│   │   ├── bin/                 # Pre-compiled server binary
│   │   └── extensions/          # Sample Lua extensions
│   ├── frontend/
│   │   ├── assets/              # castd.css, castd.js
│   │   └── presets/             # Built-in components and themes
│   ├── castd.sh            # Control script
│   ├── server.default.toml      # Server config template
│   └── bundle.default.toml      # Bundle config template
├── workspace/                   # Your content goes here
├── manuals/                     # Documentation
└── README.md
```

The `castd/` directory is the framework. Treat it as read-only —
updates arrive via `git pull upstream main`. Your work lives entirely
in `workspace/`.

### Pre-built Binaries

The distribution ships with binaries for common platforms:

| Binary | Platform |
|--------|----------|
| `castd-darwin-arm64` | macOS (Apple Silicon) |
| `castd-darwin-x86_64` | macOS (Intel) |
| `castd-linux-x86_64` | Linux (x86_64) |
| `castd-linux-arm64` | Linux (ARM64) |
| `castd-freebsd-x86_64` | FreeBSD (x86_64) |

The control script (`castd.sh`) detects your platform automatically
and selects the correct binary. No manual step required.

### Building from Source

If your platform is not listed above, or you prefer to compile
yourself, the source archive is available in each GitHub release
as `src.tar.xz`.

Extract and build:

```bash
tar xf src.tar.xz
cd castd/backend
cargo build --release
```

The compiled binary appears at `target/release/castd`. Copy it into
place with the correct platform suffix:

```bash
cp target/release/castd ../bin/castd-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
```

**Requirements:** A working [Rust](https://www.rust-lang.org/tools/install)
toolchain (stable channel). No other dependencies — SQLite and Lua are
compiled in.

---

## Configuration

### Server Configuration

Copy the template and adjust:

```bash
cp castd/server.default.toml server.toml
```

```toml
[server]
# HTTP port (default: 1337, ignored when using socket)
port = 1337

# Default bundle to serve from workspace/
bundle = "my-site"

# Unix socket for reverse proxy (production)
# socket = "/var/run/castd.sock"

[extensions]
# Lua extensions to enable
# enabled = ["discount", "checkout"]

# Maximum execution time per extension in milliseconds
# timeout_ms = 100

# Route bindings (when filename differs from route)
# [extensions.routes]
# "/checkout" = "checkout"
```

| Setting | Default | Purpose |
|---------|---------|---------|
| `port` | 1337 | HTTP port for development |
| `bundle` | — | Bundle name from `workspace/` |
| `socket` | — | Unix socket path (replaces port in production) |
| `extensions.enabled` | — | List of Lua extensions to load |
| `extensions.timeout_ms` | 100 | Maximum extension execution time |

When `bundle` is set in `server.toml`, you can start the server without
the `--bundle` flag.

### Bundle Configuration

Each bundle can have its own configuration:

```bash
cp castd/bundle.default.toml workspace/my-site/bundle.toml
```

```toml
[routing]
# Template folder for the homepage (/)
# Resolves to templates/{home}/{home}.html
home = "home"
```

The `home` setting determines which template folder serves the root URL.
With `home = "home"`, a request to `/` renders
`workspace/my-site/templates/home/home.html`.

---

## Your First Bundle

Create the bundle directory structure:

```bash
mkdir -p workspace/my-site/templates/home
mkdir -p workspace/my-site/assets/{scripts,styles,images}
mkdir -p workspace/my-site/presets/components
```

Create your first template at `workspace/my-site/templates/home/home.html`:

```html
<!doctype html>
<html lang="en-GB">
<head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light dark">
    <title>My Site</title>
    <link rel="stylesheet" href="/assets/styles/castd.css">
</head>
<body>
    <main>
        <article class="as-card show-shadow">
            <header>It works.</header>
            <p>If you can read this, the server is running.</p>
            {( cn:preset.form.button["Continue"] )}
        </article>
    </main>
    <script src="/assets/scripts/castd.js"></script>
</body>
</html>
```

Start the server:

```bash
./castd/castd.sh start --bundle my-site
```

Visit [http://127.0.0.1:1337](http://127.0.0.1:1337). You should see a
card with a button styled by the Metroline theme.

**If it does not start:**

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Binary not found" | Wrong OS/architecture | Run `ls castd/backend/bin/` to see available binaries |
| "Port already in use" | Another process on 1337 | Use `--port 8080` or stop the other process |
| "Bundle not found" | Typo in bundle name | Check `ls workspace/` |
| Blank page | Missing template | Verify `workspace/my-site/templates/home/home.html` exists |

Check the log for details:

```bash
cat castd/.castd.log
```

---

## Bundle Structure

> Every URL maps to a template folder. No routing table, no configuration
> file — the filesystem is the router.

```
workspace/my-site/
├── assets/
│   ├── scripts/             # Your JavaScript
│   ├── styles/              # Your CSS (theme overrides, custom styles)
│   └── images/              # Your images
├── presets/
│   └── components/          # Your custom presets
├── templates/
│   ├── home/
│   │   └── home.html        # → /
│   ├── about/
│   │   └── about.html       # → /about
│   └── blog/
│       ├── blog.html         # → /blog
│       └── post/
│           └── post.html     # → /blog/post
└── bundle.toml
```

### URL Resolution

| URL | Template |
|-----|----------|
| `/` | `templates/{home}/{home}.html` (from bundle.toml) |
| `/about` | `templates/about/about.html` |
| `/blog` | `templates/blog/blog.html` |
| `/blog/post` | `templates/blog/post/post.html` |

### Asset Resolution

Assets are served from two locations. Your bundle takes priority:

| Priority | Path | Purpose |
|----------|------|---------|
| 1 | `workspace/my-site/assets/` | Your assets |
| 2 | `castd/frontend/assets/` | Framework assets |

Request `/assets/styles/custom.css` → checks your bundle first, then
falls back to the framework. This is how `castd.css` is served
without copying it into your bundle.

### The Rule

**`castd/` is the framework. `workspace/` is yours.**

Never modify files inside `castd/`. Framework updates arrive
via `git pull upstream main` and would overwrite your changes. Everything
you create — templates, styles, presets, images — belongs in
`workspace/your-bundle/`.

---

## Keeping Up to Date

> Two remotes, one rule: pull framework from upstream, push your work
> to origin. They never interfere.

### The Dual-Remote Model

```
upstream (read-only)                origin (your repo)
         │                                  ▲
         │  git pull upstream main          │  git push origin main
         ▼                                  │
    ┌─────────────────────────────────────────┐
    │            my-project/                  │
    │  castd/       ← from upstream          │
    │  workspace/   ← your work → to origin  │
    └─────────────────────────────────────────┘
```

### Pulling Framework Updates

```bash
git fetch upstream
git pull upstream main
```

This updates `castd/` (binary, presets, assets) and `manuals/`.
Your `workspace/` directory is never touched by upstream — the framework
and your content live in separate directory trees.

**Conflicts are rare.** They can only occur if you modified a file that
also changed upstream. Since `castd/` is read-only for you and
`workspace/` does not exist in upstream, the trees do not overlap.

If a conflict does occur (e.g., in `README.md`), resolve it normally
and commit the merge.

### Pushing Your Work

```bash
git add -A
git commit -m "feat: add blog templates"
git push origin main
```

Your `origin` remote receives everything — framework files and your
bundle together. This is your complete project, ready to deploy.

### Update Workflow Summary

| Step | Command | What changes |
|------|---------|-------------|
| 1 | `git fetch upstream` | Download framework updates |
| 2 | `git pull upstream main` | Merge into your project |
| 3 | Test locally | Verify nothing broke |
| 4 | `git push origin main` | Push updated project to your repo |

---

## Deployment

### Development

```bash
./castd/castd.sh start --bundle my-site
# → http://127.0.0.1:1337
```

The `--port` flag overrides the default:

```bash
./castd/castd.sh start --bundle my-site --port 8080
```

### Production

For production behind a reverse proxy (Caddy, nginx), use a Unix socket:

```bash
./castd/castd.sh start --bundle my-site --socket /var/run/castd.sock
```

The reverse proxy forwards requests to the socket. No port exposed,
no firewall rules needed for the application server.

### Control Script

| Command | Purpose |
|---------|---------|
| `start` | Start the server |
| `stop` | Graceful shutdown |
| `restart` | Stop, then start |
| `status` | Check if running |

```bash
./castd/castd.sh status
# → castd is running (PID 12345)

./castd/castd.sh stop
# → castd stopped

./castd/castd.sh restart --bundle my-site
```

### Process Files

| File | Location | Purpose |
|------|----------|---------|
| PID | `castd/.castd.pid` | Process ID for stop/status |
| Log | `castd/.castd.log` | Server output and errors |

### Binary Detection

The control script automatically selects the correct binary for your
operating system and architecture:

```
castd/backend/bin/castd-{os}-{arch}
```

See [Pre-built Binaries](#pre-built-binaries) for the full list of
shipped platforms. If your platform is missing, the script lists
available binaries and shows your system details — build from source
to add your own.

---

## Next Steps

| Topic | Manual | What you learn |
|-------|--------|---------------|
| Template syntax | [CAST Reference](./05-cast-reference.md) | Five delimiters, modifiers, logic |
| Components | [Presets](./10-presets.md) | Forms, UI elements, layouts |
| CSS framework | [Framework](./07-styling.md) | Class prefixes, layers, variables |
| Theming | [Theming](./09-theming.md) | Colours, dark mode, custom themes |
| Design principles | [Concepts](./03-concepts.md) | Naming conventions, architecture |
| Business model | [Introduction](./01-introduction.md) | Why CASTD, honest limitations |

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
