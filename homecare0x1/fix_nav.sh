#!/bin/bash

echo ">>> Updating and installing missing Qt/XCB dependencies..."
sudo apt-get update && sudo apt-get install -y \
  libxcb-xinerama0 libxcb-xinerama0-dev \
  libxcb1 libxcb1-dev libx11-xcb1 \
  libxcb-randr0 libxcb-randr0-dev \
  libxcb-image0 libxcb-image0-dev \
  libxcb-util1 libxcb-util1-dev \
  libxcb-keysyms1 libxcb-keysyms1-dev \
  libglu1-mesa libxrender1 libxi6 libsm6 libxext6

echo ">>> Checking if emulator has correct Qt plugin path..."
PLUGIN_PATH="$HOME/Android/Sdk/emulator/lib64/qt/plugins/platforms"

if [ ! -f "$PLUGIN_PATH/libqxcb.so" ]; then
    echo ">>> libqxcb.so still missing. Reinstalling emulator from scratch..."
    yes | sdkmanager --uninstall "emulator"
    yes | sdkmanager --install "emulator"
fi

echo ">>> Forcing plugin path to be visible..."
export QT_QPA_PLATFORM_PLUGIN_PATH="$HOME/Android/Sdk/emulator/lib64/qt/plugins/platforms"

echo ">>> Launching emulator with headless fallback (in case GUI fails)..."
$HOME/Android/Sdk/emulator/emulator -avd ${1:-MyEmulator} || \
$HOME/Android/Sdk/emulator/emulator -avd ${1:-MyEmulator} -no-window
