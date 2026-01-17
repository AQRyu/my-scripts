#!/bin/bash

# Update all installed Flatpak applications and runtimes non-interactively
echo "Starting Flatpak update..."
flatpak update -y

# Optional: Remove unused runtimes to save space
echo "Removing unused runtimes..."
flatpak uninstall --unused -y

echo "Flatpak update complete."
