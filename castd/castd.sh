#!/bin/sh
# Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
# SPDX-License-Identifier: Apache-2.0

# castd.sh — Control script for CASTD
#
# This script manages the CASTD server in a dist/ installation.
# See CM.D.AR-011 and CM.O-006(A) for architecture details.
#
# Usage: ./castd.sh [command] [options]
#
# Commands:
#   start       Start the server
#   stop        Stop the server
#   restart     Restart the server
#   status      Show server status
#   install     Install binary to /usr/local/bin
#   uninstall   Remove binary from /usr/local/bin
#   help        Show this help
#
# Options (for start):
#   --port N    Listen on port N (default: 8080)
#   --socket P  Listen on Unix socket P
#   --bundle N  Template bundle name (workspace architecture)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BINARY_DIR="$SCRIPT_DIR/backend/bin"
PID_FILE="$SCRIPT_DIR/.castd.pid"
LOG_FILE="$SCRIPT_DIR/.castd.log"

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

BINARY_NAME="castd-${OS}-${ARCH}"
BINARY_PATH="$BINARY_DIR/$BINARY_NAME"

# Check if binary exists
check_binary() {
    if [ ! -f "$BINARY_PATH" ]; then
        echo "Error: Binary not found: $BINARY_PATH"
        echo ""
        echo "Available binaries:"
        ls -1 "$BINARY_DIR" 2>/dev/null | grep "^castd-" || echo "  (none)"
        echo ""
        echo "Your system: ${OS}-${ARCH}"
        exit 1
    fi
}

# Parse start options
parse_start_options() {
    PORT="1337"
    SOCKET=""
    BUNDLE=""

    shift  # Remove 'start' from args
    while [ $# -gt 0 ]; do
        case "$1" in
            --port)
                PORT="$2"
                shift 2
                ;;
            --socket)
                SOCKET="$2"
                shift 2
                ;;
            --bundle)
                BUNDLE="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# Start command
cmd_start() {
    check_binary

    # Stop any existing server (stale PID or port still in use)
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if kill -0 "$OLD_PID" 2>/dev/null; then
            echo "Stopping existing server (PID: $OLD_PID)..."
            kill "$OLD_PID" 2>/dev/null
            sleep 1
        fi
        rm -f "$PID_FILE"
    fi

    parse_start_options "$@"

    # Kill any process still holding the port (e.g. after unclean shutdown)
    if [ -z "$SOCKET" ]; then
        STALE_PIDS=$(lsof -ti :"$PORT" 2>/dev/null || true)
        if [ -n "$STALE_PIDS" ]; then
            echo "Killing stale process(es) on port $PORT..."
            echo "$STALE_PIDS" | xargs kill 2>/dev/null || true
            sleep 1
        fi
    fi

    echo "Starting castd server..."
    echo "  Root: $PROJECT_DIR"

    # Build command arguments
    ARGS="serve --dir $PROJECT_DIR"

    if [ -n "$BUNDLE" ]; then
        ARGS="$ARGS --bundle $BUNDLE"
        echo "  Bundle: $BUNDLE"
    fi

    if [ -n "$SOCKET" ]; then
        ARGS="$ARGS --socket $SOCKET"
        echo "  Socket: $SOCKET"
    else
        ARGS="$ARGS --port $PORT"
        echo "  Port: $PORT"
    fi

    nohup "$BINARY_PATH" $ARGS > "$LOG_FILE" 2>&1 &

    echo $! > "$PID_FILE"

    sleep 1
    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo ""
        echo "Server started (PID: $(cat "$PID_FILE"))"
        if [ -z "$SOCKET" ]; then
            echo "URL: http://127.0.0.1:$PORT"
        fi
        echo "Log: $LOG_FILE"
    else
        echo ""
        echo "Failed to start server. Check log:"
        tail -20 "$LOG_FILE"
        exit 1
    fi
}

# Stop command
cmd_stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Server not running (no PID file)"
        exit 0
    fi

    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping server (PID: $PID)..."
        kill "$PID"
        rm -f "$PID_FILE"
        echo "Server stopped."
    else
        echo "Server not running (stale PID file)"
        rm -f "$PID_FILE"
    fi
}

# Restart command
cmd_restart() {
    cmd_stop
    sleep 1
    shift  # Remove 'restart' so remaining args pass to start
    cmd_start start "$@"
}

# Status command
cmd_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Server running (PID: $PID)"
            echo "Log: $LOG_FILE"
            exit 0
        fi
    fi
    echo "Server not running"
    exit 1
}

# Install command
cmd_install() {
    check_binary
    echo "Installing castd to /usr/local/bin..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "Note: You may need sudo for this operation."
        sudo cp "$BINARY_PATH" /usr/local/bin/castd
        sudo chmod +x /usr/local/bin/castd
    else
        cp "$BINARY_PATH" /usr/local/bin/castd
        chmod +x /usr/local/bin/castd
    fi
    echo "Done. Run: castd serve --dir /path/to/project"
}

# Uninstall command
cmd_uninstall() {
    echo "Removing castd from /usr/local/bin..."
    if [ "$(id -u)" -ne 0 ]; then
        sudo rm -f /usr/local/bin/castd
    else
        rm -f /usr/local/bin/castd
    fi
    echo "Done."
}

# Help command
cmd_help() {
    cat << 'EOF'
castd.sh — Control script for CASTD

Usage: ./castd.sh [command] [options]

Commands:
  start       Start the server (single instance)
  stop        Stop the server (single instance)
  restart     Restart the server (single instance)
  status      Show server status (single instance)
  db          Database inspection and management
  service     Multi-instance project management
  install     Install binary to /usr/local/bin
  uninstall   Remove binary from /usr/local/bin
  help        Show this help

Options (for start/restart):
  --port N    Listen on port N (default: 1337)
  --socket P  Listen on Unix socket P
  --bundle N  Template bundle name (workspace architecture)

Examples:
  ./castd.sh start --bundle cm-website
  ./castd.sh start --bundle cm-website --port 3000
  ./castd.sh start --bundle mysite --socket /tmp/castd.sock
  ./castd.sh restart --bundle cm-website
  ./castd.sh stop
  ./castd.sh db tables
  ./castd.sh db read posts --where active=true
  ./castd.sh db backup

Directory Structure:
  This script expects to be in castd/ of a project:

  project/
  ├── castd/
  │   ├── backend/
  │   │   ├── bin/          Server binary
  │   │   └── hooks/        Lua extensions
  │   ├── frontend/
  │   │   ├── assets/       CSS, JS, images
  │   │   └── presets/      Components, extensions, themes
  │   └── castd.sh     (this script)
  ├── workspace/{bundle}/   Your content
  └── manuals/

Documentation: https://castd.run
EOF
}

# DB command — passthrough to binary
cmd_db() {
    check_binary
    shift  # Remove 'db'
    "$BINARY_PATH" db --dir "$PROJECT_DIR" "$@"
}

# Service command — passthrough to binary
cmd_service() {
    check_binary
    shift  # Remove 'service'
    "$BINARY_PATH" service "$@"
}

# Main
COMMAND="${1:-help}"
case "$COMMAND" in
    start)     cmd_start "$@" ;;
    stop)      cmd_stop ;;
    restart)   cmd_restart "$@" ;;
    status)    cmd_status ;;
    db)        cmd_db "$@" ;;
    service)   cmd_service "$@" ;;
    install)   cmd_install ;;
    uninstall) cmd_uninstall ;;
    help|--help|-h) cmd_help ;;
    *)
        echo "Unknown command: $COMMAND"
        echo ""
        cmd_help
        exit 1
        ;;
esac
