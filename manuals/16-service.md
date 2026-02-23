# Service Daemon

The service daemon manages multiple CASTD instances on a single machine.
Each project gets its own process, started from a central configuration file.

The daemon is a **launcher, not a supervisor**: it starts instances and exits.
Each instance runs independently — if the daemon stops, instances keep running.

---

## System Configuration

Create `/etc/castd/castd.toml` (Linux) or `/usr/local/etc/castd/castd.toml`
(FreeBSD/macOS):

```toml
[projects]
website = "/var/www/castd.run"
shop = "/var/www/shop.example.com"
docs = "/var/www/docs.example.com"
```

One line per project. The value is the project root directory.
Each project's own `castd/server.toml` controls how it runs.

Override the config path with the `CASTD_CONFIG` environment variable.

---

## Configuration Hierarchy

```
/etc/castd/castd.toml              ← WHERE (one line per project)
    │
    ├── /var/www/castd.run/
    │   └── castd/server.toml       ← HOW (port, socket, bundle)
    │
    └── /var/www/shop.example.com/
        └── castd/server.toml
```

The system config knows WHERE projects live. Each project's config
knows HOW it should run.

---

## CLI

### Start

```bash
castd service start --name=website              # Single project
castd service start --name=website,shop,docs    # Multiple projects
castd service start --name=all                  # All from castd.toml
```

### Stop

```bash
castd service stop --name=website
castd service stop --name=all
```

### Restart

```bash
castd service restart --name=website
castd service restart --name=all
```

### Status

```bash
castd service status
```

Output:

```
PROJECT          PID      SOCKET/PORT                      STATUS
docs             —        :1339                            stopped
shop             1235     /var/run/castd-shop.sock         running
website          1234     /var/run/castd-web.sock          running
```

### Reload

Re-read `castd.toml`, start any new projects, leave running ones untouched:

```bash
castd service reload
```

---

## Process Naming

Each instance sets its process title, visible in `ps aux`:

```
www  1234  castd[website]
www  1235  castd[shop]
www  1236  castd[docs]
```

---

## PID Files

Each instance writes its PID to `{project}/castd/.castd.pid`.
The daemon uses these files for stop, status, and reload operations.

---

## OS Integration

### FreeBSD (rc.d)

Copy `castd/service/castd.rc` to `/usr/local/etc/rc.d/castd`:

```bash
cp castd/service/castd.rc /usr/local/etc/rc.d/castd
chmod 755 /usr/local/etc/rc.d/castd
sysrc castd_enable="YES"
```

Then use standard service management:

```bash
service castd start
service castd stop
service castd status
service castd reload
```

### Linux (systemd)

Copy `castd/service/castd.service` to `/etc/systemd/system/`:

```bash
cp castd/service/castd.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable castd
systemctl start castd
```

---

## Per-Instance Configuration

Each project's `castd/server.toml` controls instance-specific settings:

```toml
# Socket-based (for reverse proxy)
[server]
bundle = "cm-website"
socket = "/var/run/castd-web.sock"
```

```toml
# Port-based (for development or direct access)
[server]
bundle = "cm-shop"
port = 3001
```

Socket-based is preferred for Caddy/nginx reverse proxy setups.

---

*Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.*
*SPDX-License-Identifier: Apache-2.0*
