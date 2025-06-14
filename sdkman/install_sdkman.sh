#!/bin/bash

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

echo "Updating package lists..."
sudo apt-get update

echo "Installing required packages: curl, unzip, zip"
sudo apt-get install -y curl unzip zip

echo "Installing SDKMAN!..."
curl -s "https://get.sdkman.io" | bash

echo "Sourcing SDKMAN! environment variables..."
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "Verifying SDKMAN! installation..."
sdk version

echo "SDKMAN! installation complete.  Please open a new terminal or source your bash profile to start using sdk."
