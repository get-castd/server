# 17 — Setup

> **Implementation details:** See `manuals[llm]/21-setup[llm].md` (internal)

CASTD ships with a setup script that handles installation across FreeBSD,
Linux, and macOS. Pure POSIX sh, zero external dependencies.

---

## Quick Start

```bash
# Interactive — mode selector with arrow keys
./castd/setup.sh

# Non-interactive — specify mode directly
./castd/setup.sh --standalone-pkg
./castd/setup.sh --standalone-source
./castd/setup.sh --service-pkg
./castd/setup.sh --service-source

# Pipe-safe
curl -sS https://castd.run/setup.sh | sh -s -- --standalone-pkg
```

---

## Installation Modes

### Deployment Modes

| Mode | Binary location | Use case |
|------|----------------|----------|
| **Standalone** | `castd/backend/bin/` (local) | Single project, development |
| **Service** | `/usr/local/bin/castd` | Multi-project production server |

### Installation Methods

| Method | Description |
|--------|-------------|
| **pkg install** | Download pre-built binary |
| **Source Tree Setup** | Build from source with `cargo build --release` |

The terminology mirrors FreeBSD conventions — intentional.

---

## Standalone Mode

Downloads or builds the binary into the project's `castd/backend/bin/`
directory. Creates a workspace with an example template.

```
project/
├── castd/
│   ├── backend/
│   │   └── bin/castd-{os}-{arch}    ← installed here
│   ├── frontend/
│   ├── castd.sh
│   └── setup.sh
└── workspace/
    └── my-project/
        └── templates/
            └── index.html            ← example template
```

Start with:
```bash
./castd/castd.sh start --bundle my-project
```

---

## Service Mode

Installs the binary to `/usr/local/bin/castd`, creates a service
configuration, and installs the appropriate system service unit.

### Configuration

```toml
# /usr/local/etc/castd/castd.toml (FreeBSD/macOS)
# /etc/castd/castd.toml (Linux)

[projects]
my-project = "/var/www/my-project"
```

### Service Management

**FreeBSD:**
```bash
sysrc castd_enable=YES
service castd start
```

**Linux:**
```bash
systemctl enable castd
systemctl start castd
```

See [Service](16-service.md) for the full service daemon documentation.

---

## Flags

| Flag | Description |
|------|-------------|
| `--standalone-pkg` | Standalone + download binary |
| `--standalone-source` | Standalone + build from source |
| `--service-pkg` | Service + download binary |
| `--service-source` | Service + build from source |
| `--bundle NAME` | Bundle name for workspace (default: `my-project`) |
| `--project-dir PATH` | Project directory for service mode |
| `--help`, `-h` | Show usage |

---

## Platform Support

| Platform | pkg install | Source Tree Setup | Service |
|----------|-------------|-------------------|---------|
| FreeBSD x86_64 | Yes | Yes | rc.d |
| Linux x86_64 | Yes | Yes | systemd |
| Linux arm64 | Yes | Yes | systemd |
| macOS arm64 | Yes | Yes | No |
| macOS x86_64 | Yes | Yes | No |

macOS does not support service mode (no rc.d or systemd). Use standalone
mode on macOS.

---

## Source Tree Setup

When building from source, setup.sh checks for a Rust toolchain and offers
to install it via rustup if missing. This is the only interactive prompt
during the entire setup process.

Requirements:
- Rust toolchain (1.70+)
- Internet connection (for `cargo fetch`)

The build uses `cargo build --release` with the project's optimised
release profile (size-optimised, LTO, stripped).

---

## Distribution

Pre-built binaries ship in the Git repository at `castd/backend/bin/`.
The `pkg install` method downloads the correct binary directly from
the repository — no separate release infrastructure needed.

Supported binaries:
- `castd-darwin-arm64`
- `castd-darwin-x86_64`
- `castd-linux-x86_64`
- `castd-linux-arm64`
- `castd-freebsd-x86_64`

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
