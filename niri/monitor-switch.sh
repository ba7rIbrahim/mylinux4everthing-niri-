#!/bin/bash

# Monitor names (verify using 'niri msg outputs' or 'umbriel outputs')
INTERNAL="eDP-1"
EXTERNAL=""

ROFI_THEME="$HOME/.config/rofi/launchers/type-7/style-5.rasi"

# Detect the running compositor. Umbriel exports UMBRIEL_SOCKET; the IPC
# command also fails cleanly when Niri is in charge.
if [ -n "${UMBRIEL_SOCKET:-}" ] || umbriel outputs >/dev/null 2>&1; then
  COMPOSITOR="umbriel"
else
  COMPOSITOR="niri"
fi

# Print the enabled output connectors, one per line.
list_outputs() {
  case "$COMPOSITOR" in
  umbriel)
    umbriel outputs --json 2>/dev/null | jq -r '.[] | select(.enabled) | .name'
    ;;
  niri)
    niri msg outputs 2>/dev/null | grep '^Output' | sed -n 's/.*(\(.*\)).*/\1/p'
    ;;
  esac
}

# Dynamically find any external monitor that is NOT the internal one.
EXTERNAL=$(list_outputs | grep -v -x "$INTERNAL" | head -n 1)

# Send a notification with an icon. Noctalia provides the notification daemon
# and it is restarted on output changes, so retry until it is available again.
notify() {
  for _ in $(seq 1 40); do
    if notify-send -a "Monitor" -i "$2" "Monitor Profile" "$1" 2>/dev/null; then
      return 0
    fi
    sleep 0.1
  done
}

# Noctalia (quickshell) can crash on output changes, so respawn it if it died.
# Never kill a live shell: apps launched from its launcher would close with it.
restart_shell() {
  pkill -0 -x noctalia 2>/dev/null && return 0
  pkill -0 -x qs 2>/dev/null && return 0
  setsid -f noctalia >/dev/null 2>&1
}

notify_profile() {
  case "$1" in
  "Laptop Only") notify "Laptop Screen Only" "computer-laptop" ;;
  "Dual Monitors") notify "Dual Monitors" "$HOME/.local/share/icons/dual-monitor.svg" ;;
  "External Only") notify "External Screen Only" "video-display" ;;
  esac
}

apply_profile() {
  case "$COMPOSITOR" in
  umbriel)
    case "$1" in
    "Laptop Only")
      [ -n "$EXTERNAL" ] && umbriel msg output-disable "$EXTERNAL"
      umbriel msg output-enable "$INTERNAL"
      ;;
    "Dual Monitors")
      umbriel msg output-enable "$INTERNAL"
      [ -n "$EXTERNAL" ] && umbriel msg output-enable "$EXTERNAL"
      ;;
    "External Only")
      umbriel msg output-disable "$INTERNAL"
      [ -n "$EXTERNAL" ] && umbriel msg output-enable "$EXTERNAL"
      ;;
    esac
    ;;
  niri)
    case "$1" in
    "Laptop Only")
      [ -n "$EXTERNAL" ] && niri msg output "$EXTERNAL" off
      niri msg output "$INTERNAL" on
      sleep 0.2
      niri msg action focus-monitor "$INTERNAL"
      ;;
    "Dual Monitors")
      niri msg output "$INTERNAL" on
      [ -n "$EXTERNAL" ] && niri msg output "$EXTERNAL" on
      ;;
    "External Only")
      niri msg output "$INTERNAL" off
      [ -n "$EXTERNAL" ] && niri msg output "$EXTERNAL" on
      sleep 0.2
      [ -n "$EXTERNAL" ] && niri msg action focus-monitor "$EXTERNAL"
      ;;
    esac
    ;;
  esac
}

# Map short aliases used by the keybinds to the profile names.
case "$1" in
laptop | "Laptop Only") PROFILE="Laptop Only" ;;
external | "External Only") PROFILE="External Only" ;;
dual | "Dual Monitors") PROFILE="Dual Monitors" ;;
*) PROFILE="${1:-}" ;;
esac

# Direct mode: called from a keybind with a preset name (e.g. "Dual Monitors")
if [ -n "$PROFILE" ]; then
  case "$PROFILE" in
  "Laptop Only") ;;
  *)
    if [ -z "$EXTERNAL" ]; then
      notify "HDMI not connected" "video-display"
      exit 0
    fi
    ;;
  esac
  apply_profile "$PROFILE"
  restart_shell
  notify_profile "$PROFILE"
  exit 0
fi

# Menu mode (Mod+P): check if the external monitor is connected
if [ -n "$EXTERNAL" ]; then
  menu="\uf109  Laptop Only\n\uf109 \uf108  Dual Monitors\n\uf108  External Only"
else
  menu="\uf109  Laptop Only"
fi

chosen=$(printf "%b" "$menu" | rofi -dmenu -i -p "Monitor Mode:" -theme "$ROFI_THEME")
[ -z "$chosen" ] && exit 0

# Strip the icon prefix (everything up to the first double space)
chosen="${chosen#*  }"

apply_profile "$chosen"
restart_shell
notify_profile "$chosen"
