#!/bin/sh
# Copyright 2025 Vivian Voss. Licensed under the Apache License, Version 2.0.
# SPDX-License-Identifier: Apache-2.0

# ── Embedded: m2m_libs/tui.sh ──


# m2m_libs/tui.sh — Min2Max TUI Library
#
# Pure POSIX sh. ANSI escape codes only — no ncurses, no dialog, no deps.
# Source this file: . ./m2m_libs/tui.sh
#
# Provides:
#   m2m_tui_init TITLE N       Set up panel with TITLE and N steps
#   m2m_tui_label IDX LABEL    Set the label for step IDX (1-based)
#   m2m_tui_start IDX          Mark step IDX as active
#   m2m_tui_done  IDX [INFO]   Mark step IDX as done, optional right-side info
#   m2m_tui_fail  IDX [INFO]   Mark step IDX as failed
#   m2m_tui_skip  IDX [INFO]   Mark step IDX as skipped
#   m2m_tui_log   LINE         Append a line to the rolling log
#   m2m_tui_splash TITLE SLOTS  Show splash screen, wait for keypress
#   m2m_tui_pct   N            Set progress percentage (0-100)
#   m2m_tui_draw               Redraw the full panel
#   m2m_tui_finish             Restore terminal, final draw
#   m2m_tui_fmt_time SECS      Format seconds as H:MM:SS or M:SS
#
# Non-interactive fallback: When stdout is not a terminal, all output
# is plain text — no ANSI codes, no cursor movement.
#
# IMPORTANT — Variable scoping:
# POSIX sh has no local variables. Every helper uses a unique prefix
# to avoid collisions with the draw loop and with callers:
#   _m2m_hr      → _hr_*
#   _m2m_spaces  → _sp_*
#   m2m_tui_draw → _d_*  (main loop vars)
#   Log shift    → _ls_*

# ── State ──────────────────────────────────────────────────────────

_M2M_IS_TTY=0
_M2M_WIDTH=60
_M2M_TITLE=""
_M2M_STEP_COUNT=0
_M2M_SLOT_COUNT=0
_M2M_PANEL_DRAWN=0
_M2M_PANEL_LINES=0
_M2M_PCT=0
_M2M_LOG_MAX=5
_M2M_LOG_COUNT=0

# Step storage via eval:
#   _M2M_S_{n}_STATE   0=pending 1=active 2=done 3=failed 4=skipped
#   _M2M_S_{n}_LABEL   step description
#   _M2M_S_{n}_INFO    right-side text (size, time, etc.)
# Log lines: _M2M_L_1 .. _M2M_L_{max}

# ── ANSI ───────────────────────────────────────────────────────────

_M="\033[0m"   # reset
_MB="\033[1m"  # bold
_MD="\033[2m"  # dim
_MG="\033[32m" # green
_MR="\033[31m" # red
_MY="\033[33m" # yellow

# ── Init ───────────────────────────────────────────────────────────

m2m_tui_init() {
    _M2M_TITLE="$1"
    _M2M_STEP_COUNT="$2"
    [ "$2" -gt "$_M2M_SLOT_COUNT" ] && _M2M_SLOT_COUNT="$2"
    _M2M_LOG_COUNT=0
    _M2M_PCT=0

    _init_i=1
    while [ "$_init_i" -le "$_M2M_STEP_COUNT" ]; do
        eval "_M2M_S_${_init_i}_STATE=0"
        eval "_M2M_S_${_init_i}_LABEL='Step ${_init_i}'"
        eval "_M2M_S_${_init_i}_INFO=''"
        _init_i=$((_init_i + 1))
    done

    _init_i=1
    while [ "$_init_i" -le "$_M2M_LOG_MAX" ]; do
        eval "_M2M_L_${_init_i}=''"
        _init_i=$((_init_i + 1))
    done

    if [ -t 1 ]; then
        _M2M_IS_TTY=1
        if command -v tput >/dev/null 2>&1; then
            _init_w=$(tput cols 2>/dev/null || echo 60)
            if [ "$_init_w" -gt 80 ]; then _M2M_WIDTH=72
            elif [ "$_init_w" -gt 60 ]; then _M2M_WIDTH=60
            else _M2M_WIDTH=$((_init_w - 2)); fi
        fi
        printf "\033[?25l"  # hide cursor
    else
        _M2M_IS_TTY=0
        _M=""; _MB=""; _MD=""; _MG=""; _MR=""; _MY=""
    fi
}

# ── Step API ───────────────────────────────────────────────────────

m2m_tui_label() { eval "_M2M_S_${1}_LABEL=\$2"; }

m2m_tui_start() {
    eval "_M2M_S_${1}_STATE=1"
    eval "_M2M_S_${1}_INFO='···'"
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        eval "_api_l=\$_M2M_S_${1}_LABEL"
        printf "[....] %s\n" "$_api_l"
    fi
    m2m_tui_draw
}

m2m_tui_done() {
    eval "_M2M_S_${1}_STATE=2"
    [ -n "$2" ] && eval "_M2M_S_${1}_INFO=\$2"
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        eval "_api_l=\$_M2M_S_${1}_LABEL"
        eval "_api_r=\$_M2M_S_${1}_INFO"
        printf "[ OK ] %s  %s\n" "$_api_l" "$_api_r"
    fi
    m2m_tui_draw
}

m2m_tui_fail() {
    eval "_M2M_S_${1}_STATE=3"
    [ -n "$2" ] && eval "_M2M_S_${1}_INFO=\$2"
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        eval "_api_l=\$_M2M_S_${1}_LABEL"
        eval "_api_r=\$_M2M_S_${1}_INFO"
        printf "[FAIL] %s  %s\n" "$_api_l" "$_api_r"
    fi
    m2m_tui_draw
}

m2m_tui_skip() {
    eval "_M2M_S_${1}_STATE=4"
    [ -n "$2" ] && eval "_M2M_S_${1}_INFO=\${2:-skipped}"
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        eval "_api_l=\$_M2M_S_${1}_LABEL"
        printf "[SKIP] %s\n" "$_api_l"
    fi
    m2m_tui_draw
}

# ── Log ────────────────────────────────────────────────────────────

m2m_tui_log() {
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        printf "       %s\n" "$1"
        return
    fi

    if [ "$_M2M_LOG_COUNT" -lt "$_M2M_LOG_MAX" ]; then
        _M2M_LOG_COUNT=$((_M2M_LOG_COUNT + 1))
        eval "_M2M_L_${_M2M_LOG_COUNT}=\$1"
    else
        # Shift up
        _ls_i=1
        while [ "$_ls_i" -lt "$_M2M_LOG_MAX" ]; do
            _ls_next=$((_ls_i + 1))
            eval "_M2M_L_${_ls_i}=\$_M2M_L_${_ls_next}"
            _ls_i=$((_ls_i + 1))
        done
        eval "_M2M_L_${_M2M_LOG_MAX}=\$1"
    fi
    m2m_tui_draw
}

# ── Splash ─────────────────────────────────────────────────────────

m2m_tui_splash() {
    _spl_title="${1:-CASTD}"
    _spl_slots="${2:-10}"

    # Initialise dimensions (sets _M2M_WIDTH, _M2M_SLOT_COUNT, hides cursor)
    m2m_tui_init "$_spl_title" "$_spl_slots"

    [ "$_M2M_IS_TTY" -eq 0 ] && return

    _spl_w="$_M2M_WIDTH"
    _spl_in=$((_spl_w - 2))
    _spl_total=$((_M2M_SLOT_COUNT + _M2M_LOG_MAX + 7))

    # Logo lines — leading space on lines 1 and 6 is part of the art
    _spl_logo1=" ██████╗ █████╗ ███████╗████████╗██████╗ "
    _spl_logo2="██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔══██╗"
    _spl_logo3="██║     ███████║███████╗   ██║   ██║  ██║"
    _spl_logo4="██║     ██╔══██║╚════██║   ██║   ██║  ██║"
    _spl_logo5="╚██████╗██║  ██║███████║   ██║   ██████╔╝"
    _spl_logo6=" ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ "

    _spl_logo_w=42
    _spl_lpad=$(( (_spl_in - _spl_logo_w) / 2 ))

    # Vertical layout: 6 logo + 1 blank + 1 "Press Key" = 8 centred content lines
    # Copyright sits fixed on the penultimate row (1 blank above bottom border)
    _spl_content=8
    _spl_above=$(( (_spl_total - 2 - _spl_content - 2) / 2 ))
    _spl_below=$(( _spl_total - 2 - _spl_content - 2 - _spl_above ))

    _spl_pk="Press Key"
    _spl_pklen=${#_spl_pk}
    _spl_pkpad=$(( (_spl_in - _spl_pklen) / 2 ))
    _spl_pkrpad=$((_spl_in - _spl_pkpad - _spl_pklen))

    _spl_cr="2026 - by Vivian Voss under Apache 2 Licence"
    _spl_crlen=${#_spl_cr}
    _spl_crpad=$(( (_spl_in - _spl_crlen) / 2 ))
    _spl_crrpad=$((_spl_in - _spl_crpad - _spl_crlen))

    # _spl_draw_frame SHOW_TEXT (1=visible, 0=hidden)
    _spl_draw_frame() {
        _spl_show="$1"

        # Overwrite previous frame
        if [ "$_spl_redrawn" -eq 1 ]; then
            printf "\033[%dA" "$_spl_total"
        fi
        _spl_redrawn=1

        # Top border
        _spl_tlen=${#_spl_title}
        _spl_dashes=$((_spl_in - _spl_tlen - 3))
        printf "┌─ ${_MB}%s${_M} " "$_spl_title"
        _spl_i=0; while [ "$_spl_i" -lt "$_spl_dashes" ]; do printf "─"; _spl_i=$((_spl_i + 1)); done
        printf "┐\n"

        # Blank above
        _spl_i=0; while [ "$_spl_i" -lt "$_spl_above" ]; do
            printf "│"; _m2m_spaces "$_spl_in"; printf "│\n"
            _spl_i=$((_spl_i + 1))
        done

        # Logo
        _spl_li=1
        while [ "$_spl_li" -le 6 ]; do
            eval "_spl_ll=\$_spl_logo${_spl_li}"
            _spl_lllen=${#_spl_ll}
            _spl_rpad=$((_spl_in - _spl_lpad - _spl_lllen))
            [ "$_spl_rpad" -lt 0 ] && _spl_rpad=0
            printf "│"
            _m2m_spaces "$_spl_lpad"
            printf "${_MG}%s${_M}" "$_spl_ll"
            _m2m_spaces "$_spl_rpad"
            printf "│\n"
            _spl_li=$((_spl_li + 1))
        done

        # Blank
        printf "│"; _m2m_spaces "$_spl_in"; printf "│\n"

        # Press Key (visible or hidden)
        printf "│"
        _m2m_spaces "$_spl_pkpad"
        if [ "$_spl_show" -eq 1 ]; then
            printf "${_MD}%s${_M}" "$_spl_pk"
        else
            _m2m_spaces "$_spl_pklen"
        fi
        _m2m_spaces "$_spl_pkrpad"
        printf "│\n"

        # Blank below
        _spl_i=0; while [ "$_spl_i" -lt "$_spl_below" ]; do
            printf "│"; _m2m_spaces "$_spl_in"; printf "│\n"
            _spl_i=$((_spl_i + 1))
        done

        # Blank before copyright
        printf "│"; _m2m_spaces "$_spl_in"; printf "│\n"

        # Copyright (fixed, penultimate row)
        printf "│"
        _m2m_spaces "$_spl_crpad"
        printf "${_MD}%s${_M}" "$_spl_cr"
        _m2m_spaces "$_spl_crrpad"
        printf "│\n"

        # Bottom border
        printf "└"
        _m2m_hr "$_spl_in"
        printf "┘\n"
    }

    # Initial draw
    _spl_redrawn=0
    _spl_draw_frame 1

    # Blink loop: redraw entire frame with text toggled
    _spl_old=$(stty -g)
    stty -icanon min 0 time 5 -echo
    _spl_vis=1
    while true; do
        _spl_key=""
        _spl_key=$(dd bs=1 count=1 2>/dev/null)
        if [ -n "$_spl_key" ]; then break; fi
        _spl_vis=$(( 1 - _spl_vis ))
        _spl_draw_frame "$_spl_vis"
    done
    stty "$_spl_old"

    # Set panel state so next view overwrites this one
    _M2M_PANEL_DRAWN=1
    _M2M_PANEL_LINES="$_spl_total"
}

# ── Progress ───────────────────────────────────────────────────────

m2m_tui_pct() { _M2M_PCT="$1"; }

# ── Time formatting ────────────────────────────────────────────────

m2m_tui_fmt_time() {
    _ft_s="$1"
    if [ "$_ft_s" -ge 3600 ]; then
        printf "%d:%02d:%02d" $((_ft_s / 3600)) $((_ft_s % 3600 / 60)) $((_ft_s % 60))
    elif [ "$_ft_s" -ge 60 ]; then
        printf "%d:%02d" $((_ft_s / 60)) $((_ft_s % 60))
    else
        printf "0:%02d" "$_ft_s"
    fi
}

# ── Draw ───────────────────────────────────────────────────────────

m2m_tui_draw() {
    [ "$_M2M_IS_TTY" -eq 0 ] && return

    _d_w="$_M2M_WIDTH"
    _d_in=$((_d_w - 2))

    # Panel: top + blank + SLOTS + blank + progress + blank + 5 log + blank + bottom
    _d_lines=$((_M2M_SLOT_COUNT + _M2M_LOG_MAX + 7))

    # Overwrite previous frame
    _d_prev="$_M2M_PANEL_LINES"
    if [ "$_M2M_PANEL_DRAWN" -eq 1 ]; then
        printf "\033[%dA" "$_d_prev"
    fi
    _M2M_PANEL_DRAWN=1
    _M2M_PANEL_LINES="$_d_lines"

    # ── Top border ──
    _d_tlen=${#_M2M_TITLE}
    _d_dashes=$((_d_in - _d_tlen - 3))
    printf "┌─ ${_MB}%s${_M} " "$_M2M_TITLE"
    _m2m_hr "$_d_dashes"
    printf "┐\n"

    # ── Blank ──
    _m2m_eline "$_d_in"

    # ── Steps ──
    _d_si=1
    while [ "$_d_si" -le "$_M2M_STEP_COUNT" ]; do
        eval "_d_st=\$_M2M_S_${_d_si}_STATE"
        eval "_d_lb=\$_M2M_S_${_d_si}_LABEL"
        eval "_d_nf=\$_M2M_S_${_d_si}_INFO"

        case "$_d_st" in
            0) _d_ic="  " ;;
            1) _d_ic="${_MY}· ${_M}" ;;
            2) _d_ic="${_MG}✓ ${_M}" ;;
            3) _d_ic="${_MR}✗ ${_M}" ;;
            4) _d_ic="${_MD}– ${_M}" ;;
        esac

        _d_nflen=${#_d_nf}
        _d_lbmax=$((_d_in - 6 - _d_nflen))
        [ "$_d_lbmax" -lt 4 ] && _d_lbmax=4
        _d_lbvis=$(printf "%.${_d_lbmax}s" "$_d_lb")
        _d_lbvlen=${#_d_lbvis}
        _d_pad=$((_d_in - 6 - _d_lbvlen - _d_nflen))
        [ "$_d_pad" -lt 0 ] && _d_pad=0

        printf "│  %b%s" "$_d_ic" "$_d_lbvis"
        _m2m_spaces "$_d_pad"
        [ -n "$_d_nf" ] && printf "%s" "$_d_nf"
        printf "  │\n"

        _d_si=$((_d_si + 1))
    done

    # ── Empty slot rows (pad to SLOT_COUNT) ──
    _d_si="$_M2M_STEP_COUNT"
    while [ "$_d_si" -lt "$_M2M_SLOT_COUNT" ]; do
        _m2m_eline "$_d_in"
        _d_si=$((_d_si + 1))
    done

    # ── Blank ──
    _m2m_eline "$_d_in"

    # ── Progress bar ──
    _d_bw=$((_d_in - 18))
    [ "$_d_bw" -lt 10 ] && _d_bw=10
    _d_filled=$((_M2M_PCT * _d_bw / 100))
    _d_empty=$((_d_bw - _d_filled))

    printf "│  ${_MG}"
    _d_bi=0; while [ "$_d_bi" -lt "$_d_filled" ]; do printf "█"; _d_bi=$((_d_bi + 1)); done
    printf "${_MD}"
    _d_bi=0; while [ "$_d_bi" -lt "$_d_empty" ];  do printf "·"; _d_bi=$((_d_bi + 1)); done
    printf "${_M}  %3d%%" "$_M2M_PCT"

    _d_used=$((2 + _d_bw + 2 + 4))
    _d_rpad=$((_d_in - _d_used))
    [ "$_d_rpad" -gt 0 ] && _m2m_spaces "$_d_rpad"
    printf "│\n"

    # ── Blank ──
    _m2m_eline "$_d_in"

    # ── Log lines ──
    _d_li=1
    while [ "$_d_li" -le "$_M2M_LOG_MAX" ]; do
        if [ "$_d_li" -le "$_M2M_LOG_COUNT" ]; then
            eval "_d_ll=\$_M2M_L_${_d_li}"
            _d_llvis=$(printf "%.${_d_in}s" "$_d_ll")
            _d_lllen=${#_d_llvis}
            _d_llpad=$((_d_in - _d_lllen))
            printf "│${_MD}%s${_M}" "$_d_llvis"
            _m2m_spaces "$_d_llpad"
            printf "│\n"
        else
            _m2m_eline "$_d_in"
        fi
        _d_li=$((_d_li + 1))
    done

    # ── Blank ──
    _m2m_eline "$_d_in"

    # ── Bottom border ──
    printf "└"
    _m2m_hr "$_d_in"
    printf "┘\n"

    # Clear leftover lines from a taller previous panel
    if [ "$_d_prev" -gt "$_d_lines" ]; then
        _d_ci=0
        _d_clear=$((_d_prev - _d_lines))
        while [ "$_d_ci" -lt "$_d_clear" ]; do
            printf "\033[2K\n"
            _d_ci=$((_d_ci + 1))
        done
        # Move cursor back up to sit right after the bottom border
        printf "\033[%dA" "$_d_clear"
    fi
}

# ── Finish ─────────────────────────────────────────────────────────

m2m_tui_finish() {
    m2m_tui_draw
    _M2M_PANEL_DRAWN=0
    _M2M_PANEL_LINES=0
    _M2M_SLOT_COUNT=0
    [ "$_M2M_IS_TTY" -eq 1 ] && printf "\033[?25h"
}

# ── Internal helpers (unique var prefixes to avoid collisions) ─────

_m2m_hr() {
    _hr_c="$1"; _hr_i=0
    while [ "$_hr_i" -lt "$_hr_c" ]; do printf "─"; _hr_i=$((_hr_i + 1)); done
}

_m2m_spaces() {
    _sp_c="$1"; _sp_i=0
    while [ "$_sp_c" -gt 0 ] && [ "$_sp_i" -lt "$_sp_c" ]; do printf " "; _sp_i=$((_sp_i + 1)); done
}

_m2m_eline() {
    printf "│"
    _m2m_spaces "$1"
    printf "│\n"
}

# ── Setup script ──


# setup.sh — CASTD installation script
#
# Pure POSIX sh. Zero dependencies. Works on FreeBSD, Linux, macOS.
#
# Usage:
#   ./castd/setup.sh                    Interactive mode selection
#   ./castd/setup.sh --standalone-pkg   Non-interactive: standalone + download
#   ./castd/setup.sh --standalone-source Non-interactive: standalone + build
#   ./castd/setup.sh --service-pkg      Non-interactive: service + download
#   ./castd/setup.sh --service-source   Non-interactive: service + build
#   ./castd/setup.sh --bundle mysite    Specify bundle name for workspace
#
# Modes:
#   Standalone + pkg install      Download binary, local project dir
#   Standalone + Source Tree Setup Build from source, local project dir
#   Service + pkg install          Download to /usr/local/bin, rc.d/systemd
#   Service + Source Tree Setup    Build + install to /usr/local/bin

set -e

# ── Source TUI (dev only; stripped by server-release.sh) ──────────
SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Constants ─────────────────────────────────────────────────────

CASTD_RAW_URL="https://raw.githubusercontent.com/get-castd/server/main"
CASTD_BIN_PATH="castd/backend/bin"

# ── State (set by detection / selection) ──────────────────────────

CASTD_OS=""
CASTD_ARCH=""
CASTD_OS_LABEL=""
CASTD_ARCH_LABEL=""
CASTD_BINARY=""
CASTD_BUNDLE="my-project"
CASTD_MODE_DEPLOY=""   # 0=standalone, 1=service
CASTD_MODE_METHOD=""   # 0=pkg, 1=source
CASTD_PROJECT_DIR=""
_dl_cmd=""

# ── Platform detection ────────────────────────────────────────────

detect_platform() {
    CASTD_OS="$(uname -s)"
    CASTD_ARCH="$(uname -m)"

    case "$CASTD_OS" in
        Darwin)  CASTD_OS_LABEL="darwin" ;;
        Linux)   CASTD_OS_LABEL="linux" ;;
        FreeBSD) CASTD_OS_LABEL="freebsd" ;;
        *) return 1 ;;
    esac

    case "$CASTD_ARCH" in
        x86_64|amd64) CASTD_ARCH_LABEL="x86_64" ;;
        arm64|aarch64) CASTD_ARCH_LABEL="arm64" ;;
        *) return 1 ;;
    esac

    CASTD_BINARY="castd-${CASTD_OS_LABEL}-${CASTD_ARCH_LABEL}"
}

# ── Download tool detection ───────────────────────────────────────

detect_downloader() {
    if command -v fetch >/dev/null 2>&1; then
        _dl_cmd="fetch"
    elif command -v curl >/dev/null 2>&1; then
        _dl_cmd="curl"
    elif command -v wget >/dev/null 2>&1; then
        _dl_cmd="wget"
    else
        return 1
    fi
}

# ── Download file ─────────────────────────────────────────────────

download_file() {
    _df_url="$1"
    _df_out="$2"

    case "$_dl_cmd" in
        fetch) fetch -qo "$_df_out" "$_df_url" ;;
        curl)  curl -sSL -o "$_df_out" "$_df_url" ;;
        wget)  wget -qO "$_df_out" "$_df_url" ;;
    esac
}

# ── Mode selection (interactive) ──────────────────────────────────

_ds_line() {
    # Print a bordered line: │ {content} {pad} │
    # $1 = visible text (plain, no ANSI)
    # $2 = actual printf content (may contain ANSI)
    _dsl_vis="$1"
    _dsl_raw="$2"
    _dsl_vlen=${#_dsl_vis}
    _dsl_pad=$((_ds_in - _dsl_vlen))
    [ "$_dsl_pad" -lt 0 ] && _dsl_pad=0
    printf "│%b" "$_dsl_raw"
    _sp_c="$_dsl_pad"; _sp_i=0
    while [ "$_sp_i" -lt "$_sp_c" ]; do printf " "; _sp_i=$((_sp_i + 1)); done
    printf "│\n"
}

_draw_selection() {
    _ds_deploy="$1"
    _ds_method="$2"
    _ds_group="$3"
    _ds_in=$((_M2M_WIDTH - 2))

    # Total lines must match TUI panel: SLOT_COUNT + LOG_MAX + 7
    _ds_total=$((_M2M_SLOT_COUNT + _M2M_LOG_MAX + 7))
    # Content lines: top + 12 content rows + bottom = 14
    _ds_content=14
    _ds_pad_rows=$((_ds_total - _ds_content))
    [ "$_ds_pad_rows" -lt 0 ] && _ds_pad_rows=0

    # Overwrite previous frame
    if [ "$_ds_drawn" -eq 1 ]; then
        printf "\033[%dA" "$_ds_total"
    fi
    _ds_drawn=1

    # Top border
    _ds_tlen=11  # "CASTD Setup"
    _ds_dashes=$((_ds_in - _ds_tlen - 3))
    printf "┌─ ${_MB}CASTD Setup${_M} "
    _ds_i=0; while [ "$_ds_i" -lt "$_ds_dashes" ]; do printf "─"; _ds_i=$((_ds_i + 1)); done
    printf "┐\n"

    _ds_line "" ""
    _ds_line "  Select deployment mode:" "  Select deployment mode:"
    _ds_line "" ""

    # Standalone
    if [ "$_ds_deploy" -eq 0 ]; then
        if [ "$_ds_group" -eq 0 ]; then
            _ds_line "  > Standalone    (single project)" "  ${_MG}›${_M} ${_MB}Standalone${_M}    (single project)"
        else
            _ds_line "  > Standalone    (single project)" "  ${_MG}›${_M} Standalone    (single project)"
        fi
    else
        _ds_line "    Standalone    (single project)" "    Standalone    (single project)"
    fi

    # Service
    if [ "$_ds_deploy" -eq 1 ]; then
        if [ "$_ds_group" -eq 0 ]; then
            _ds_line "  > Service       (multi-project daemon)" "  ${_MG}›${_M} ${_MB}Service${_M}       (multi-project daemon)"
        else
            _ds_line "  > Service       (multi-project daemon)" "  ${_MG}›${_M} Service       (multi-project daemon)"
        fi
    else
        _ds_line "    Service       (multi-project daemon)" "    Service       (multi-project daemon)"
    fi

    _ds_line "" ""
    _ds_line "  Select installation method:" "  Select installation method:"
    _ds_line "" ""

    # pkg install
    if [ "$_ds_method" -eq 0 ]; then
        if [ "$_ds_group" -eq 1 ]; then
            _ds_line "  > pkg install      (pre-built binary)" "  ${_MG}›${_M} ${_MB}pkg install${_M}      (pre-built binary)"
        else
            _ds_line "  > pkg install      (pre-built binary)" "  ${_MG}›${_M} pkg install      (pre-built binary)"
        fi
    else
        _ds_line "    pkg install      (pre-built binary)" "    pkg install      (pre-built binary)"
    fi

    # Source Tree Setup
    if [ "$_ds_method" -eq 1 ]; then
        if [ "$_ds_group" -eq 1 ]; then
            _ds_line "  > Source Tree Setup (build from source)" "  ${_MG}›${_M} ${_MB}Source Tree Setup${_M} (build from source)"
        else
            _ds_line "  > Source Tree Setup (build from source)" "  ${_MG}›${_M} Source Tree Setup (build from source)"
        fi
    else
        _ds_line "    Source Tree Setup (build from source)" "    Source Tree Setup (build from source)"
    fi

    _ds_line "" ""
    _ds_line "  Platform: ${CASTD_OS} ${CASTD_ARCH}" "  Platform: ${CASTD_OS} ${CASTD_ARCH}"

    # Pad to panel height
    _ds_pi=0
    while [ "$_ds_pi" -lt "$_ds_pad_rows" ]; do
        _ds_line "" ""
        _ds_pi=$((_ds_pi + 1))
    done

    # Bottom border
    printf "└"
    _ds_i=0; while [ "$_ds_i" -lt "$_ds_in" ]; do printf "─"; _ds_i=$((_ds_i + 1)); done
    printf "┘\n"
}

select_mode() {
    # Skip if flags already set mode
    if [ -n "$CASTD_MODE_DEPLOY" ] && [ -n "$CASTD_MODE_METHOD" ]; then
        return 0
    fi

    # Non-interactive fallback
    if [ "$_M2M_IS_TTY" -eq 0 ]; then
        select_mode_plain
        return
    fi

    _sel_deploy=0
    _sel_method=0
    _sel_group=0
    _sel_done=0

    # If splash was shown, overwrite it on first draw
    if [ "$_M2M_PANEL_DRAWN" -eq 1 ]; then
        _ds_drawn=1
        _ds_prev_lines="$_M2M_PANEL_LINES"
        _M2M_PANEL_DRAWN=0
    else
        _ds_drawn=0
        _ds_prev_lines=0
    fi

    _old_stty=$(stty -g)

    while [ "$_sel_done" -eq 0 ]; do
        _draw_selection "$_sel_deploy" "$_sel_method" "$_sel_group"

        stty raw -echo
        _key=$(dd bs=1 count=1 2>/dev/null)
        stty "$_old_stty"

        case "$_key" in
            "$(printf '\033')")
                stty raw -echo
                _k2=$(dd bs=1 count=1 2>/dev/null)
                _k3=$(dd bs=1 count=1 2>/dev/null)
                stty "$_old_stty"
                case "$_k3" in
                    A|B)
                        if [ "$_sel_group" -eq 0 ]; then
                            _sel_deploy=$(( (_sel_deploy + 1) % 2 ))
                        else
                            _sel_method=$(( (_sel_method + 1) % 2 ))
                        fi
                        ;;
                esac
                # Also handle \033O sequences (some terminals)
                case "$_k2" in
                    O)
                        case "$_k3" in
                            A|B)
                                if [ "$_sel_group" -eq 0 ]; then
                                    _sel_deploy=$(( (_sel_deploy + 1) % 2 ))
                                else
                                    _sel_method=$(( (_sel_method + 1) % 2 ))
                                fi
                                ;;
                        esac
                        ;;
                esac
                ;;
            "$(printf '\t')")
                _sel_group=$(( (_sel_group + 1) % 2 ))
                ;;
            "")
                _sel_done=1
                ;;
            q|Q)
                printf "\033[?25h"
                echo ""
                echo "Setup cancelled."
                exit 0
                ;;
        esac
    done

    CASTD_MODE_DEPLOY="$_sel_deploy"
    CASTD_MODE_METHOD="$_sel_method"

    # Hand panel state to the TUI so the first draw overwrites the selection
    _M2M_PANEL_DRAWN=1
    _M2M_PANEL_LINES=$((_M2M_SLOT_COUNT + _M2M_LOG_MAX + 7))
}

select_mode_plain() {
    printf "\nDeployment mode:\n"
    printf "  1) Standalone (single project)\n"
    printf "  2) Service (multi-project daemon)\n"
    printf "Select [1]: "
    read _dm
    case "$_dm" in
        2) CASTD_MODE_DEPLOY=1 ;;
        *) CASTD_MODE_DEPLOY=0 ;;
    esac

    printf "\nInstallation method:\n"
    printf "  1) pkg install (pre-built binary)\n"
    printf "  2) Source Tree Setup (build from source)\n"
    printf "Select [1]: "
    read _im
    case "$_im" in
        2) CASTD_MODE_METHOD=1 ;;
        *) CASTD_MODE_METHOD=0 ;;
    esac
}

# ── Step: Download binary ─────────────────────────────────────────

step_download_binary() {
    _sdb_idx="$1"
    _sdb_dest="$2"

    detect_downloader || {
        m2m_tui_fail "$_sdb_idx" "no download tool"
        m2m_tui_log "  Install curl, wget, or fetch"
        return 1
    }

    _sdb_url="${CASTD_RAW_URL}/${CASTD_BIN_PATH}/${CASTD_BINARY}"
    _sdb_tmp="$(mktemp)"

    m2m_tui_log "  ${_sdb_url}"
    download_file "$_sdb_url" "$_sdb_tmp" || {
        rm -f "$_sdb_tmp"
        m2m_tui_fail "$_sdb_idx" "download failed"
        return 1
    }

    if [ ! -s "$_sdb_tmp" ]; then
        rm -f "$_sdb_tmp"
        m2m_tui_fail "$_sdb_idx" "empty file"
        return 1
    fi

    mkdir -p "$(dirname "$_sdb_dest")"
    mv "$_sdb_tmp" "$_sdb_dest"
    chmod +x "$_sdb_dest"
}

# ── Step: Check Rust toolchain ────────────────────────────────────

step_check_rust() {
    _scr_idx="$1"

    if command -v rustc >/dev/null 2>&1; then
        _scr_ver=$(rustc --version | cut -d' ' -f2)
        m2m_tui_done "$_scr_idx" "$_scr_ver"
        return 0
    fi

    m2m_tui_log "  Rust not found."

    if [ "$_M2M_IS_TTY" -eq 1 ]; then
        printf "\n  Install Rust? [y/N] "
    else
        printf "  Install Rust? [y/N] "
    fi
    read _answer

    case "$_answer" in
        y|Y)
            m2m_tui_log "  Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet
            . "$HOME/.cargo/env"
            _scr_ver=$(rustc --version | cut -d' ' -f2)
            m2m_tui_done "$_scr_idx" "$_scr_ver"
            ;;
        *)
            m2m_tui_fail "$_scr_idx" "Rust required"
            return 1
            ;;
    esac
}

# ── Step: Build from source ───────────────────────────────────────

step_build_source() {
    _sbs_idx="$1"
    _sbs_dest="$2"
    _sbs_backend="$SETUP_DIR/backend"

    if [ ! -f "$_sbs_backend/Cargo.toml" ]; then
        m2m_tui_fail "$_sbs_idx" "no Cargo.toml"
        m2m_tui_log "  Expected: $_sbs_backend/Cargo.toml"
        return 1
    fi

    m2m_tui_log "  cargo build --release"
    cd "$_sbs_backend"

    if cargo build --release --quiet 2>/dev/null; then
        mkdir -p "$(dirname "$_sbs_dest")"
        cp "target/release/castd" "$_sbs_dest"
        chmod +x "$_sbs_dest"
        _sbs_size=$(du -h "$_sbs_dest" | cut -f1 | tr -d ' ')
        m2m_tui_done "$_sbs_idx" "$_sbs_size"
    else
        m2m_tui_fail "$_sbs_idx" "build failed"
        return 1
    fi
}

# ── Step: Install binary ─────────────────────────────────────────

step_install_binary() {
    _sib_idx="$1"
    _sib_src="$2"
    _sib_dest="$3"

    mkdir -p "$(dirname "$_sib_dest")"

    if [ "$(dirname "$_sib_dest")" = "/usr/local/bin" ]; then
        if [ "$(id -u)" -ne 0 ]; then
            m2m_tui_log "  Requires root (using sudo)"
            sudo cp "$_sib_src" "$_sib_dest"
            sudo chmod +x "$_sib_dest"
        else
            cp "$_sib_src" "$_sib_dest"
            chmod +x "$_sib_dest"
        fi
    else
        cp "$_sib_src" "$_sib_dest"
        chmod +x "$_sib_dest"
    fi

    _sib_size=$(du -h "$_sib_dest" | cut -f1 | tr -d ' ')
    m2m_tui_done "$_sib_idx" "$_sib_size"
}

# ── Step: Create service config ───────────────────────────────────

step_create_config() {
    _scc_idx="$1"

    case "$CASTD_OS" in
        FreeBSD|Darwin) _scc_dir="/usr/local/etc/castd" ;;
        Linux)          _scc_dir="/etc/castd" ;;
    esac

    _scc_file="$_scc_dir/castd.toml"

    if [ -f "$_scc_file" ]; then
        m2m_tui_log "  Config exists, adding project"
        # Append project if not already listed
        if ! grep -q "^${CASTD_BUNDLE}" "$_scc_file" 2>/dev/null; then
            if [ "$(id -u)" -ne 0 ]; then
                printf '%s = "%s"\n' "$CASTD_BUNDLE" "$CASTD_PROJECT_DIR" | sudo tee -a "$_scc_file" >/dev/null
            else
                printf '%s = "%s"\n' "$CASTD_BUNDLE" "$CASTD_PROJECT_DIR" >> "$_scc_file"
            fi
        fi
        m2m_tui_done "$_scc_idx" "$_scc_file"
        return
    fi

    if [ "$(id -u)" -ne 0 ]; then
        sudo mkdir -p "$_scc_dir"
        cat << EOF | sudo tee "$_scc_file" >/dev/null
# CASTD service configuration
# Maps project names to their root directories.

[projects]
${CASTD_BUNDLE} = "${CASTD_PROJECT_DIR}"
EOF
    else
        mkdir -p "$_scc_dir"
        cat << EOF > "$_scc_file"
# CASTD service configuration
# Maps project names to their root directories.

[projects]
${CASTD_BUNDLE} = "${CASTD_PROJECT_DIR}"
EOF
    fi

    m2m_tui_done "$_scc_idx" "$_scc_file"
}

# ── Step: Install service unit ────────────────────────────────────

step_install_unit() {
    _siu_idx="$1"

    case "$CASTD_OS" in
        FreeBSD)
            _siu_src="$SETUP_DIR/service/castd.rc"
            _siu_dest="/usr/local/etc/rc.d/castd"
            if [ ! -f "$_siu_src" ]; then
                m2m_tui_skip "$_siu_idx" "rc.d template missing"
                return 0
            fi
            if [ "$(id -u)" -ne 0 ]; then
                sudo cp "$_siu_src" "$_siu_dest"
                sudo chmod 755 "$_siu_dest"
            else
                cp "$_siu_src" "$_siu_dest"
                chmod 755 "$_siu_dest"
            fi
            m2m_tui_log "  Installed: $_siu_dest"
            m2m_tui_done "$_siu_idx" "rc.d"
            ;;
        Linux)
            _siu_src="$SETUP_DIR/service/castd.service"
            _siu_dest="/etc/systemd/system/castd.service"
            if [ ! -f "$_siu_src" ]; then
                m2m_tui_skip "$_siu_idx" "systemd template missing"
                return 0
            fi
            if [ "$(id -u)" -ne 0 ]; then
                sudo cp "$_siu_src" "$_siu_dest"
                sudo systemctl daemon-reload
            else
                cp "$_siu_src" "$_siu_dest"
                systemctl daemon-reload
            fi
            m2m_tui_log "  Installed: $_siu_dest"
            m2m_tui_done "$_siu_idx" "systemd"
            ;;
        Darwin)
            m2m_tui_log "  macOS: no system service available"
            m2m_tui_skip "$_siu_idx" "not available"
            ;;
    esac
}

# ── Step: Create workspace ────────────────────────────────────────

step_create_workspace() {
    _scw_idx="$1"
    _scw_dir="$2"

    mkdir -p "$_scw_dir/templates"
    m2m_tui_done "$_scw_idx" "$_scw_dir"
}

# ── Step: Write example template ──────────────────────────────────

step_write_example() {
    _swe_idx="$1"
    _swe_dir="$2"

    cat > "$_swe_dir/templates/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>CASTD</title>
</head>
<body>
    <h1>It works.</h1>
    <p>CASTD is running. Edit workspace/templates/ to get started.</p>
</body>
</html>
EOF

    m2m_tui_done "$_swe_idx" "index.html"
}

# ── Completion screens ────────────────────────────────────────────

show_complete_standalone() {
    _sc_bin="$1"
    _sc_ws="$2"
    _sc_size=$(du -h "$_sc_bin" | cut -f1 | tr -d ' ')
    _sc_w=44

    echo ""
    printf "┌─ ${_MB}Setup Complete${_M} "
    _sc_i=0; while [ "$_sc_i" -lt 28 ]; do printf "─"; _sc_i=$((_sc_i + 1)); done
    printf "┐\n"
    printf "│                                            │\n"
    printf "│  ${_MG}✓${_M} CASTD installed (standalone)          │\n"
    printf "│                                            │\n"
    printf "│  Binary: %-33s │\n" "$_sc_bin"
    printf "│  Bundle: %-33s │\n" "$_sc_ws"
    printf "│  Size:   %-33s │\n" "$_sc_size"
    printf "│                                            │\n"
    printf "│  Start the server:                         │\n"
    printf "│  ./castd/castd.sh start --bundle %-8s │\n" "$CASTD_BUNDLE"
    printf "│                                            │\n"
    printf "│  Documentation: https://castd.run          │\n"
    printf "│                                            │\n"
    printf "└"
    _sc_i=0; while [ "$_sc_i" -lt "$_sc_w" ]; do printf "─"; _sc_i=$((_sc_i + 1)); done
    printf "┘\n"
}

show_complete_service() {
    _sc_bin="$1"
    _sc_cfg="$2"
    _sc_prj="$3"
    _sc_size=$(du -h "$_sc_bin" | cut -f1 | tr -d ' ')
    _sc_w=44

    echo ""
    printf "┌─ ${_MB}Setup Complete${_M} "
    _sc_i=0; while [ "$_sc_i" -lt 28 ]; do printf "─"; _sc_i=$((_sc_i + 1)); done
    printf "┐\n"
    printf "│                                            │\n"
    printf "│  ${_MG}✓${_M} CASTD installed (service)             │\n"
    printf "│                                            │\n"
    printf "│  Binary:  %-32s │\n" "$_sc_bin"
    printf "│  Config:  %-32s │\n" "$_sc_cfg"
    printf "│  Project: %-32s │\n" "$_sc_prj"
    printf "│  Size:    %-32s │\n" "$_sc_size"
    printf "│                                            │\n"
    printf "│  Start the service:                        │\n"
    printf "│  castd service start --name=%-13s │\n" "$CASTD_BUNDLE"
    printf "│                                            │\n"
    printf "│  Or enable at boot:                        │\n"
    case "$CASTD_OS" in
        FreeBSD)
    printf "│  sysrc castd_enable=YES                    │\n"
    printf "│  service castd start                       │\n"
            ;;
        Linux)
    printf "│  systemctl enable castd                    │\n"
    printf "│  systemctl start castd                     │\n"
            ;;
        *)
    printf "│  (no system service on this platform)      │\n"
    printf "│                                            │\n"
            ;;
    esac
    printf "│                                            │\n"
    printf "│  Documentation: https://castd.run          │\n"
    printf "│                                            │\n"
    printf "└"
    _sc_i=0; while [ "$_sc_i" -lt "$_sc_w" ]; do printf "─"; _sc_i=$((_sc_i + 1)); done
    printf "┘\n"
}

# ── Execution flow: Standalone + pkg install ──────────────────────

run_standalone_pkg() {
    _rsp_project="$(cd "$SETUP_DIR/.." && pwd)"
    _rsp_bin="$SETUP_DIR/backend/bin/$CASTD_BINARY"
    _rsp_ws="$_rsp_project/workspace/$CASTD_BUNDLE"

    m2m_tui_init "CASTD Setup  standalone + pkg" 6
    m2m_tui_label 1 "Detecting platform"
    m2m_tui_label 2 "Downloading binary"
    m2m_tui_label 3 "Installing binary"
    m2m_tui_label 4 "Creating workspace"
    m2m_tui_label 5 "Writing example template"
    m2m_tui_label 6 "Setup complete"
    m2m_tui_pct 0
    m2m_tui_draw

    # Step 1: Detect platform
    m2m_tui_start 1
    if detect_platform; then
        m2m_tui_done 1 "${CASTD_OS_LABEL} ${CASTD_ARCH_LABEL}"
    else
        m2m_tui_fail 1 "unsupported platform"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 16

    # Step 2: Download binary
    m2m_tui_start 2
    _rsp_tmp="$(mktemp)"
    step_download_binary 2 "$_rsp_tmp" || { m2m_tui_finish; return 1; }
    _rsp_size=$(du -h "$_rsp_tmp" | cut -f1 | tr -d ' ')
    m2m_tui_done 2 "$_rsp_size"
    m2m_tui_pct 33

    # Step 3: Install binary
    m2m_tui_start 3
    step_install_binary 3 "$_rsp_tmp" "$_rsp_bin"
    rm -f "$_rsp_tmp"
    m2m_tui_pct 50

    # Step 4: Create workspace
    m2m_tui_start 4
    step_create_workspace 4 "$_rsp_ws"
    m2m_tui_pct 66

    # Step 5: Write example
    m2m_tui_start 5
    step_write_example 5 "$_rsp_ws"
    m2m_tui_pct 83

    # Step 6: Complete
    m2m_tui_start 6
    m2m_tui_done 6
    m2m_tui_pct 100
    m2m_tui_finish

    show_complete_standalone "$_rsp_bin" "$_rsp_ws"
}

# ── Execution flow: Standalone + Source Tree Setup ────────────────

run_standalone_source() {
    _rss_project="$(cd "$SETUP_DIR/.." && pwd)"
    _rss_bin="$SETUP_DIR/backend/bin/$CASTD_BINARY"
    _rss_ws="$_rss_project/workspace/$CASTD_BUNDLE"

    m2m_tui_init "Source Tree Setup  standalone" 8
    m2m_tui_label 1 "Detecting platform"
    m2m_tui_label 2 "Checking Rust toolchain"
    m2m_tui_label 3 "Resolving dependencies"
    m2m_tui_label 4 "Building server binary"
    m2m_tui_label 5 "Installing binary"
    m2m_tui_label 6 "Creating workspace"
    m2m_tui_label 7 "Writing example template"
    m2m_tui_label 8 "Setup complete"
    m2m_tui_pct 0
    m2m_tui_draw

    # Step 1: Detect platform
    m2m_tui_start 1
    if detect_platform; then
        m2m_tui_done 1 "${CASTD_OS_LABEL} ${CASTD_ARCH_LABEL}"
    else
        m2m_tui_fail 1 "unsupported platform"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 12

    # Step 2: Check Rust
    m2m_tui_start 2
    step_check_rust 2 || { m2m_tui_finish; return 1; }
    m2m_tui_pct 25

    # Step 3: Resolve dependencies
    m2m_tui_start 3
    m2m_tui_log "  cargo fetch"
    cd "$SETUP_DIR/backend"
    if cargo fetch --quiet 2>/dev/null; then
        m2m_tui_done 3
    else
        m2m_tui_fail 3 "fetch failed"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 37

    # Step 4: Build
    m2m_tui_start 4
    _rss_tmp="$(mktemp)"
    step_build_source 4 "$_rss_tmp" || { rm -f "$_rss_tmp"; m2m_tui_finish; return 1; }
    m2m_tui_pct 62

    # Step 5: Install binary
    m2m_tui_start 5
    step_install_binary 5 "$_rss_tmp" "$_rss_bin"
    rm -f "$_rss_tmp"
    m2m_tui_pct 75

    # Step 6: Create workspace
    m2m_tui_start 6
    step_create_workspace 6 "$_rss_ws"
    m2m_tui_pct 82

    # Step 7: Write example
    m2m_tui_start 7
    step_write_example 7 "$_rss_ws"
    m2m_tui_pct 90

    # Step 8: Complete
    m2m_tui_start 8
    m2m_tui_done 8
    m2m_tui_pct 100
    m2m_tui_finish

    show_complete_standalone "$_rss_bin" "$_rss_ws"
}

# ── Execution flow: Service + pkg install ─────────────────────────

run_service_pkg() {
    _rsvp_bin="/usr/local/bin/castd"
    CASTD_PROJECT_DIR="${CASTD_PROJECT_DIR:-/var/www/${CASTD_BUNDLE}}"

    case "$CASTD_OS" in
        FreeBSD|Darwin) _rsvp_cfg="/usr/local/etc/castd/castd.toml" ;;
        Linux)          _rsvp_cfg="/etc/castd/castd.toml" ;;
    esac
    _rsvp_ws="$CASTD_PROJECT_DIR/workspace/$CASTD_BUNDLE"

    m2m_tui_init "CASTD Setup  service + pkg" 8
    m2m_tui_label 1 "Detecting platform"
    m2m_tui_label 2 "Downloading binary"
    m2m_tui_label 3 "Installing binary"
    m2m_tui_label 4 "Creating config"
    m2m_tui_label 5 "Installing service"
    m2m_tui_label 6 "Creating workspace"
    m2m_tui_label 7 "Writing example template"
    m2m_tui_label 8 "Setup complete"
    m2m_tui_pct 0
    m2m_tui_draw

    # Step 1: Detect platform
    m2m_tui_start 1
    if detect_platform; then
        m2m_tui_done 1 "${CASTD_OS_LABEL} ${CASTD_ARCH_LABEL}"
    else
        m2m_tui_fail 1 "unsupported platform"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 12

    # Step 2: Download binary
    m2m_tui_start 2
    _rsvp_tmp="$(mktemp)"
    step_download_binary 2 "$_rsvp_tmp" || { m2m_tui_finish; return 1; }
    _rsvp_size=$(du -h "$_rsvp_tmp" | cut -f1 | tr -d ' ')
    m2m_tui_done 2 "$_rsvp_size"
    m2m_tui_pct 25

    # Step 3: Install binary
    m2m_tui_start 3
    step_install_binary 3 "$_rsvp_tmp" "$_rsvp_bin"
    rm -f "$_rsvp_tmp"
    m2m_tui_pct 37

    # Step 4: Create config
    m2m_tui_start 4
    step_create_config 4
    m2m_tui_pct 50

    # Step 5: Install service unit
    m2m_tui_start 5
    step_install_unit 5
    m2m_tui_pct 62

    # Step 6: Create workspace
    m2m_tui_start 6
    step_create_workspace 6 "$_rsvp_ws"
    m2m_tui_pct 75

    # Step 7: Write example
    m2m_tui_start 7
    step_write_example 7 "$_rsvp_ws"
    m2m_tui_pct 87

    # Step 8: Complete
    m2m_tui_start 8
    m2m_tui_done 8
    m2m_tui_pct 100
    m2m_tui_finish

    show_complete_service "$_rsvp_bin" "$_rsvp_cfg" "$CASTD_PROJECT_DIR"
}

# ── Execution flow: Service + Source Tree Setup ───────────────────

run_service_source() {
    _rsvs_bin="/usr/local/bin/castd"
    CASTD_PROJECT_DIR="${CASTD_PROJECT_DIR:-/var/www/${CASTD_BUNDLE}}"

    case "$CASTD_OS" in
        FreeBSD|Darwin) _rsvs_cfg="/usr/local/etc/castd/castd.toml" ;;
        Linux)          _rsvs_cfg="/etc/castd/castd.toml" ;;
    esac
    _rsvs_ws="$CASTD_PROJECT_DIR/workspace/$CASTD_BUNDLE"

    m2m_tui_init "Source Tree Setup  service" 10
    m2m_tui_label 1 "Detecting platform"
    m2m_tui_label 2 "Checking Rust toolchain"
    m2m_tui_label 3 "Resolving dependencies"
    m2m_tui_label 4 "Building server binary"
    m2m_tui_label 5 "Installing binary"
    m2m_tui_label 6 "Creating config"
    m2m_tui_label 7 "Installing service"
    m2m_tui_label 8 "Creating workspace"
    m2m_tui_label 9 "Writing example template"
    m2m_tui_label 10 "Setup complete"
    m2m_tui_pct 0
    m2m_tui_draw

    # Step 1: Detect platform
    m2m_tui_start 1
    if detect_platform; then
        m2m_tui_done 1 "${CASTD_OS_LABEL} ${CASTD_ARCH_LABEL}"
    else
        m2m_tui_fail 1 "unsupported platform"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 10

    # Step 2: Check Rust
    m2m_tui_start 2
    step_check_rust 2 || { m2m_tui_finish; return 1; }
    m2m_tui_pct 20

    # Step 3: Resolve dependencies
    m2m_tui_start 3
    m2m_tui_log "  cargo fetch"
    cd "$SETUP_DIR/backend"
    if cargo fetch --quiet 2>/dev/null; then
        m2m_tui_done 3
    else
        m2m_tui_fail 3 "fetch failed"
        m2m_tui_finish
        return 1
    fi
    m2m_tui_pct 30

    # Step 4: Build
    m2m_tui_start 4
    _rsvs_tmp="$(mktemp)"
    step_build_source 4 "$_rsvs_tmp" || { rm -f "$_rsvs_tmp"; m2m_tui_finish; return 1; }
    m2m_tui_pct 50

    # Step 5: Install binary
    m2m_tui_start 5
    step_install_binary 5 "$_rsvs_tmp" "$_rsvs_bin"
    rm -f "$_rsvs_tmp"
    m2m_tui_pct 60

    # Step 6: Create config
    m2m_tui_start 6
    step_create_config 6
    m2m_tui_pct 70

    # Step 7: Install service unit
    m2m_tui_start 7
    step_install_unit 7
    m2m_tui_pct 75

    # Step 8: Create workspace
    m2m_tui_start 8
    step_create_workspace 8 "$_rsvs_ws"
    m2m_tui_pct 82

    # Step 9: Write example
    m2m_tui_start 9
    step_write_example 9 "$_rsvs_ws"
    m2m_tui_pct 90

    # Step 10: Complete
    m2m_tui_start 10
    m2m_tui_done 10
    m2m_tui_pct 100
    m2m_tui_finish

    show_complete_service "$_rsvs_bin" "$_rsvs_cfg" "$CASTD_PROJECT_DIR"
}

# ── Usage ─────────────────────────────────────────────────────────

usage() {
    cat << 'EOF'
setup.sh — CASTD installation script

Usage: ./castd/setup.sh [options]

Options:
  --standalone-pkg      Standalone + download pre-built binary
  --standalone-source   Standalone + build from source
  --service-pkg         Service + download pre-built binary
  --service-source      Service + build from source
  --bundle NAME         Bundle name for workspace (default: my-project)
  --project-dir PATH    Project directory for service mode
  --help, -h            Show this help

Without flags, an interactive mode selector is shown.

Pipe-safe:
  curl -sS https://castd.run/setup.sh | sh -s -- --standalone-pkg
EOF
}

# ── Entry point ───────────────────────────────────────────────────

main() {
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --standalone-pkg)    CASTD_MODE_DEPLOY=0; CASTD_MODE_METHOD=0; shift ;;
            --standalone-source) CASTD_MODE_DEPLOY=0; CASTD_MODE_METHOD=1; shift ;;
            --service-pkg)       CASTD_MODE_DEPLOY=1; CASTD_MODE_METHOD=0; shift ;;
            --service-source)    CASTD_MODE_DEPLOY=1; CASTD_MODE_METHOD=1; shift ;;
            --bundle)            CASTD_BUNDLE="$2"; shift 2 ;;
            --project-dir)       CASTD_PROJECT_DIR="$2"; shift 2 ;;
            --help|-h)           usage; exit 0 ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Detect platform early (needed for mode selection display)
    detect_platform || true

    # Splash screen (interactive only, no flags given)
    if [ -z "$CASTD_MODE_DEPLOY" ] && [ -z "$CASTD_MODE_METHOD" ] && [ -t 1 ]; then
        m2m_tui_splash "CASTD Setup" 10
    fi

    # Interactive mode selection if no flags given
    select_mode

    # Dispatch
    if [ "$CASTD_MODE_DEPLOY" -eq 0 ] && [ "$CASTD_MODE_METHOD" -eq 0 ]; then
        run_standalone_pkg
    elif [ "$CASTD_MODE_DEPLOY" -eq 0 ] && [ "$CASTD_MODE_METHOD" -eq 1 ]; then
        run_standalone_source
    elif [ "$CASTD_MODE_DEPLOY" -eq 1 ] && [ "$CASTD_MODE_METHOD" -eq 0 ]; then
        run_service_pkg
    elif [ "$CASTD_MODE_DEPLOY" -eq 1 ] && [ "$CASTD_MODE_METHOD" -eq 1 ]; then
        run_service_source
    fi
}

main "$@"
