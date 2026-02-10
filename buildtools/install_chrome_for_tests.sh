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
  INSTALLED_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+\.\d+' || echo "unknown")
  echo "Google Chrome is already installed: $INSTALLED_VERSION"
  
  # GitHub Actions runners come with Chrome pre-installed.
  # We use whatever version is available, relying on MOCHA_WEBDRIVER_IGNORE_CHROME_VERSION=1
  # (set in test/init-mocha-webdriver.js) to handle version mismatches.
  echo "Using pre-installed Chrome version."
else
  echo "Google Chrome not found. Installing from official repository..."
  # Add Google's signing key and repository (using modern method)
  wget -q -O /tmp/google-chrome-key.pub https://dl.google.com/linux/linux_signing_key.pub
  sudo mkdir -p /etc/apt/keyrings
  sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg /tmp/google-chrome-key.pub
  sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
  rm /tmp/google-chrome-key.pub
  # Update and install latest stable version
  sudo apt-get update -qq
  sudo apt-get install -y google-chrome-stable
  INSTALLED_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+\.\d+' || echo "unknown")
  echo "Google Chrome installed successfully: $INSTALLED_VERSION"
fi

# Ensure chromedriver is available and compatible
# The selenium-webdriver package includes selenium-manager which automatically
# downloads and manages the correct chromedriver version for the installed Chrome.
if command -v chromedriver &> /dev/null; then
  CHROMEDRIVER_VERSION=$(chromedriver --version | grep -oP '\d+\.\d+\.\d+\.\d+' || echo "unknown")
  echo "Chromedriver is already available: $CHROMEDRIVER_VERSION"
else
  echo "Chromedriver not found. It will be automatically managed by selenium-manager when tests run."
fi

echo "Chrome setup complete. Version: $(google-chrome --version)"
