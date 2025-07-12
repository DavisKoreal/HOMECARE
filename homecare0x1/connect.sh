#!/bin/bash

# Updated script to troubleshoot ADB pairing and Flutter setup issues

# Function to check if ADB is installed
check_adb_installed() {
    if ! command -v adb &> /dev/null; then
        echo "ADB is not installed. Please install Android SDK Platform Tools."
        exit 1
    fi
}

# Function to update ADB
update_adb() {
    echo "Checking for ADB updates..."
    if command -v sdkmanager &> /dev/null; then
        echo "Updating platform-tools via sdkmanager..."
        sdkmanager "platform-tools"
    else
        echo "sdkmanager not found. Please download the latest platform-tools from:"
        echo "https://developer.android.com/studio/releases/platform-tools"
        echo "Extract and replace /usr/lib/android-sdk/platform-tools/adb"
        read -p "Press Enter after updating ADB manually, or Ctrl+C to exit."
    fi
    adb --version
}

# Function to kill any running ADB processes
kill_adb_processes() {
    echo "Killing any running ADB processes..."
    adb kill-server
    sleep 2
    if pgrep adb > /dev/null; then
        echo "Found residual ADB processes, terminating..."
        pkill -9 adb
    fi
}

# Function to start ADB server
start_adb_server() {
    echo "Starting ADB server..."
    adb start-server
    if [ $? -ne 0 ]; then
        echo "Failed to start ADB server. Please check your ADB installation."
        exit 1
    fi
}

# Function to clear .android cache
clear_android_cache() {
    echo "Clearing ~/.android cache..."
    rm -rf ~/.android
    echo "Cache cleared. ADB will recreate necessary files."
}

# Function to prompt for IP, port, and pairing code
prompt_for_pairing_info() {
    echo "Please check your Android device for Wireless Debugging details."
    read -p "Enter the device IP address (e.g., 10.8.0.11): " device_ip
    read -p "Enter the port number (e.g., 46565): " device_port
    read -p "Enter the pairing code (e.g., 492323): " pairing_code
    echo "$device_ip:$device_port $pairing_code"
}

# Function to attempt ADB pairing
attempt_adb_pairing() {
    local ip_port=$1
    local code=$2
    echo "Attempting to pair with $ip_port..."
    echo "$code" | adb pair "$ip_port"
    if [ $? -eq 0 ]; then
        echo "Pairing successful!"
        return 0
    else
        echo "Pairing failed. Check the IP, port, and code, then try again."
        return 1
    fi
}

# Function to retry pairing with verbose logging
retry_with_verbose() {
    local ip_port=$1
    local code=$2
    echo "Retrying pairing with verbose logging..."
    export ADB_TRACE=all
    echo "$code" | adb pair "$ip_port"
    unset ADB_TRACE
}

# Function to check network connectivity
check_network() {
    local ip=$1
    echo "Checking network connectivity to $ip..."
    ping -c 3 "$ip" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Network connectivity to $ip is good."
    else
        echo "Cannot reach $ip. Ensure the device is on the same network and no firewall/VPN is blocking."
        exit 1
    fi
}

# Function to check connected devices
check_adb_devices() {
    echo "Checking connected devices..."
    adb devices
}

# Function to fix Flutter Android toolchain
fix_flutter_toolchain() {
    if [ -f "pubspec.yaml" ] && command -v flutter &> /dev/null; then
        echo "Detected Flutter project. Fixing Android toolchain..."
        echo "Installing cmdline-tools..."
        if command -v sdkmanager &> /dev/null; then
            sdkmanager "cmdline-tools;latest"
        else
            echo "sdkmanager not found. Please install it via Android Studio or manually:"
            echo "https://developer.android.com/studio#command-line-tools-only"
            read -p "Press Enter after installing cmdline-tools, or Ctrl+C to skip."
        fi
        echo "Accepting Android licenses..."
        flutter doctor --android-licenses
        echo "Running flutter doctor..."
        flutter doctor
    fi
}

# Main script
echo "Starting updated ADB troubleshooting script..."

# Step 1: Check if ADB is installed
check_adb_installed

# Step 2: Update ADB
update_adb

# Step 3: Kill and restart ADB server
kill_adb_processes
start_adb_server

# Step 4: Clear .android cache
clear_android_cache

# Step 5: Prompt for pairing information
pairing_info=$(prompt_for_pairing_info)
ip_port=$(echo "$pairing_info" | awk '{print $1}')
pairing_code=$(echo "$pairing_info" | awk '{print $2}')
device_ip=$(echo "$ip_port" | cut -d':' -f1)

# Step 6: Check network connectivity
check_network "$device_ip"

# Step 7: Attempt pairing (up to 2 retries)
attempt_adb_pairing "$ip_port" "$pairing_code"
if [ $? -ne 0 ]; then
    echo "Pairing attempt failed. Please recheck Wireless Debugging details."
    pairing_info=$(prompt_for_pairing_info)
    ip_port=$(echo "$pairing_info" | awk '{print $1}')
    pairing_code=$(echo "$pairing_info" | awk '{print $2}')
    retry_with_verbose "$ip_port" "$pairing_code"
    if [ $? -ne 0 ]; then
        echo "Pairing still failed. Please verify:"
        echo "- The device is on the same network."
        echo "- Wireless Debugging is enabled and the IP/port/code are correct."
        echo "- No firewall or VPN is blocking the connection."
        echo "- The Android device has the latest system updates."
        echo "You may also try connecting via USB to test ADB functionality."
        exit 1
    fi
fi

# Step 8: Check connected devices
check_adb_devices

# Step 9: Fix Flutter Android toolchain
fix_flutter_toolchain

echo "Troubleshooting complete. If the issue persists, consider:"
echo "- Rebooting the device and computer."
echo "- Disabling any firewall or VPN temporarily."
echo "- Checking for conflicting software (e.g., emulators)."
echo "- Reporting the issue to the Android bug tracker with verbose logs."