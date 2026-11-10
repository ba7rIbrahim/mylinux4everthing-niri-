#!/bin/bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

# Function to move all workspaces to a specific monitor
move_workspaces_to() {
  local target=$1
  # Get all active workspaces and move them to the target monitor
  for ws in $(hyprctl workspaces -j | jq -r '.[] | .id'); do
    hyprctl dispatch moveworkspacetomonitor "$ws $target"
  done
}

# Get current status
INT_DISABLED=$(hyprctl monitors all -j | jq -r ".[] | select(.name == \"$INTERNAL\") | .disabled")
EXT_DISABLED=$(hyprctl monitors all -j | jq -r ".[] | select(.name == \"$EXTERNAL\") | .disabled")

if [ "$INT_DISABLED" == "true" ]; then
  # Mode: External Only -> Switch to: BOTH
  hyprctl keyword monitor "$INTERNAL, preferred, 0x0, 1"
  hyprctl keyword monitor "$EXTERNAL, preferred, 1920x0, 1"
  notify-send "Display Mode" "Extended Desktop (Both)" -t 2000

elif [ "$EXT_DISABLED" == "true" ]; then
  # Mode: Laptop Only -> Switch to: EXTERNAL ONLY
  # First: Move everything to External, then disable Internal
  move_workspaces_to "$EXTERNAL"
  hyprctl keyword monitor "$EXTERNAL, preferred, 0x0, 1"
  hyprctl keyword monitor "$INTERNAL, disable"
  notify-send "Display Mode" "External Monitor Only" -t 2000

else
  # Mode: Both -> Switch to: LAPTOP ONLY
  # First: Move everything to Internal, then disable External
  move_workspaces_to "$INTERNAL"
  hyprctl keyword monitor "$INTERNAL, preferred, 0x0, 1"
  hyprctl keyword monitor "$EXTERNAL, disable"
  notify-send "Display Mode" "Laptop Screen Only" -t 2000
fi
