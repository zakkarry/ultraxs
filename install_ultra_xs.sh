#!/bin/bash
#
# This cross-seed install script is written by zakkarry (https://github.com/zakkarry)
# a cross-seed dev working to bring cross-seed to ultra.cc
#
# If you find any problems or would like to make any suggestions, you can make a
# GitHub issue on the repository for this script at https://github.com/zakkarry/ultraxs
#
#

# Define the directory to check
CS_ULTRA_DIR="$HOME/.cs-ultra"
PACKAGE_JSON="$CS_ULTRA_DIR/package.json"

# Function to parse the version from package.json
get_local_version() {
  if [ -f "$PACKAGE_JSON" ]; then
    sed -n '3s/.*"\([^"]\+\)".*/\1/p' "$PACKAGE_JSON"
  else
    echo "N/A"
  fi
}

# Function to get the latest version from GitHub
get_latest_version() {
  curl -s https://api.github.com/repos/cross-seed/cross-seed/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Function to set up alias for cross-seed daemon
setup_alias() {
  ALIAS_CMD="alias cross-seed=\"NODE_OPTIONS=--disable-wasm-trap-handler NODE_VERSION=22 node $CS_ULTRA_DIR/dist/cmd.js\""
  if ! grep -Fxq "$ALIAS_CMD" "$HOME/.bashrc"; then
    echo "$ALIAS_CMD" >>"$HOME/.bashrc"
    echo "Alias 'cross-seed' added. Please restart your shell or run 'source ~/.bashrc' before attempting to start cross-seed."
  else
    echo "Alias 'cross-seed' is already set up. You may run cross-seed now."
  fi
  echo
}

# Main logic
if [ -d "$CS_ULTRA_DIR" ]; then
  echo
  echo "Detected previous ultra.cc installation of cross-seed."
  echo
  local_version=$(get_local_version)
  echo "Local version: $local_version"

  # shellcheck disable=SC2162
  read -p "Do you want to check for updates? (y/n): " choice

  if [ "$choice" == "y" ]; then
    latest_version=$(get_latest_version)

    echo
    echo "Latest version: $latest_version"
    echo
    if [ "$local_version" == "N/A" ]; then
      echo "Critical files are missing from your installation. Reinstallation is necessary."
      # shellcheck disable=SC2162
      read -p "Do you want to reinstall? (y/n): " reinstall_choice
      echo
      if [ "$reinstall_choice" == "y" ]; then
        echo "Reinstalling..."
        echo
        rm -rf "$CS_ULTRA_DIR"
        git clone https://github.com/cross-seed/cross-seed.git "$CS_ULTRA_DIR"
        cd "$CS_ULTRA_DIR" || exit
        git checkout ultra
        npm install .
        echo
        echo "Transpiling cross-seed..."
        npm run build
        echo "Reinstallation complete."
        echo
        setup_alias
      else
        echo "Reinstallation canceled."
      fi
    elif [ "$local_version" != "$latest_version" ]; then
      # shellcheck disable=SC2162
      read -p "A new version is available. Do you want to update? (y/n): " update_choice
      if [ "$update_choice" == "y" ]; then
        echo "Updating to version $latest_version..."
        echo
        rm -rf "$CS_ULTRA_DIR"
        git clone https://github.com/cross-seed/cross-seed.git "$CS_ULTRA_DIR"
        cd "$CS_ULTRA_DIR" || exit
        git checkout ultra
        npm install .
        echo
        echo "Transpiling cross-seed..."
        npm run build
        echo "Update complete."
        echo
        setup_alias
      else
        echo "Update canceled."
      fi
    else
      echo "You are already on the latest version."
    fi
  else
    echo "Exiting."
    exit 0
  fi
else
  echo "Directory $CS_ULTRA_DIR does not exist."
  # shellcheck disable=SC2162
  read -p "Do you want to install? (y/n): " install_choice
  echo
  if [ "$install_choice" == "y" ]; then
    echo "Installing..."
    git clone https://github.com/cross-seed/cross-seed.git "$CS_ULTRA_DIR"
    cd "$CS_ULTRA_DIR" || exit
    git checkout ultra
    npm install .
    echo
    echo "Transpiling cross-seed..."
    npm run build
    echo "Installation complete."
    echo
    setup_alias
  else
    echo "Exiting."
    exit 0
  fi
fi
