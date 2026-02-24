# CASTD Distribution

Distribution package for the CASTD stackless webserver.

## Quick Start

```bash
# Start the server with your bundle
./castd/castd.sh start --bundle my-project

# Or with custom port
./castd/castd.sh start --bundle my-project --port 3000

# Stop the server
./castd/castd.sh stop
```

## Directory Structure

```
dist/
├── castd/           # Framework (DO NOT MODIFY)
│   ├── backend/
│   │   ├── bin/          # Server binary
│   │   └── extensions/   # Lua extensions (sample: currency_convert)
│   ├── frontend/
│   │   ├── assets/       # CSS, JS, images
│   │   └── presets/      # Components, extensions, themes
│   └── castd.sh     # Control script
├── workspace/            # Your bundles go here
│   └── my-project/       # Example bundle
│       ├── assets/
│       ├── presets/
│       └── templates/
└── manuals/              # Documentation
```

## Creating a Bundle

1. Create a directory in `workspace/`:
   ```bash
   mkdir -p workspace/my-project/{assets,presets,templates}
   ```

2. Add your templates to `workspace/my-project/templates/`

3. Start the server:
   ```bash
   ./castd/castd.sh start --bundle my-project
   ```

## Documentation

Visit [castd.run](https://castd.run) for full documentation.

## Source Code

The complete source code is included in `castd/backend/src.tar.xz`.

```bash
tar xf castd/backend/src.tar.xz
cargo build --release
```

## Licence

Apache-2.0 — Copyright 2025 Vivian Voss. See `LICENSE` and `NOTICE`.
