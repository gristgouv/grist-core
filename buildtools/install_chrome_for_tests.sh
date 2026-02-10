#!/usr/bin/env bash

set -e

if [[ "$1" != "-y" ]]; then
  echo "Usage: $0 -y"
  echo "Installs Google Chrome and chromedriver for running end-to-end Selenium tests in GitHub."
  exit 1
fi
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Error: This script can only be run on Linux."
  exit 1
fi
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "Error: This script can only be run on amd64 architecture."
  exit 1
fi

# Check if Chrome is already installed
if command -v google-chrome &> /dev/null; then
  INSTALLED_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+\.\d+')
  echo "Google Chrome is already installed: $INSTALLED_VERSION"
else
  echo "Installing Google Chrome stable from official repository..."
  # Add Google's signing key and repository (using modern method)
  wget -q -O /tmp/google-chrome-key.pub https://dl.google.com/linux/linux_signing_key.pub
  sudo mkdir -p /etc/apt/keyrings
  sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg /tmp/google-chrome-key.pub
  sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
  rm /tmp/google-chrome-key.pub
  # Update and install
  sudo apt-get update
  sudo apt-get install -y google-chrome-stable
  echo "Google Chrome installed successfully"
fi

# Ensure chromedriver is set up using selenium-manager
if [[ -d "node_modules/selenium-webdriver/bin/linux" ]]; then
  echo "Setting up chromedriver using selenium-manager..."
  node_modules/selenium-webdriver/bin/linux/selenium-manager --driver chromedriver
  echo "Chromedriver setup complete"
else
  echo "Warning: selenium-webdriver not found in node_modules. Skipping chromedriver setup."
  echo "Note: selenium-manager will handle chromedriver automatically when tests run."
fi

echo "Chrome setup complete. Version: $(google-chrome --version)"
