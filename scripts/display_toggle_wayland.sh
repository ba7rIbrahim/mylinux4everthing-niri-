#!/bin/bash

# Replace with your actual display names
LAPTOP_DISPLAY="eDP-1"
HDMI_DISPLAY="HDMI-A-1"

# Get list of active monitors
ACTIVE_MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Function to move all workspaces to a monitor
move_all_workspaces() {
  local target_monitor=$1

  # Get all workspace IDs that currently exist
  local workspaces=$(hyprctl workspaces -j | jq -r '.[].id')

  # Move each workspace to target monitor
  for ws in $workspaces; do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$target_monitor" 2>/dev/null
  done

  # Also try to move default workspaces 1-10 just in case
  for i in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor "$i" "$target_monitor" 2>/dev/null
  done
}

# Check if HDMI is currently active
if echo "$ACTIVE_MONITORS" | grep -q "$HDMI_DISPLAY"; then
  # HDMI is active, switching to laptop only
  notify-send "Display Switch" "Switching to Laptop..." -i video-display

  # First enable laptop if it's disabled
  hyprctl keyword monitor "$LAPTOP_DISPLAY,preferred,auto,1"
  sleep 0.5

  # Move all workspaces to laptop
  move_all_workspaces "$LAPTOP_DISPLAY"
  sleep 0.5

  # Focus workspace 1 on laptop
  hyprctl dispatch focusmonitor "$LAPTOP_DISPLAY"
  hyprctl dispatch workspace 1
  sleep 0.3

  # Now disable HDMI
  hyprctl keyword monitor "$HDMI_DISPLAY,disable"

  notify-send "Display Switch" "✓ Laptop Display Active" -i video-display
else
  # Laptop is active, switching to HDMI only
  notify-send "Display Switch" "Switching to HDMI..." -i video-display

  # First enable HDMI if it's disabled
  hyprctl keyword monitor "$HDMI_DISPLAY,preferred,auto,1"
  sleep 0.5

  # Move all workspaces to HDMI
  move_all_workspaces "$HDMI_DISPLAY"
  sleep 0.5

  # Focus workspace 1 on HDMI
  hyprctl dispatch focusmonitor "$HDMI_DISPLAY"
  hyprctl dispatch workspace 1
  sleep 0.3

  # Now disable laptop display
  hyprctl keyword monitor "$LAPTOP_DISPLAY,disable"

  notify-send "Display Switch" "✓ HDMI Display Active" -i video-display
fi
