#!/bin/bash

# === CONFIG ===
DEVICE_MATCH="Yubico"     # Match devices containing "Yubico"
# ===============

echo "🔍 Auto-detecting remote IP (Windows client)..."

# Detect the IP of the XRDP client (Windows PC)
REMOTE_IP=$(ss -tnp | grep gnome-remote-de | grep ESTAB | awk '{print $5}' | sed -e 's/^\[::ffff://' -e 's/^\[//' -e 's/\]:.*$//')

# Fallback: try a different method if nothing found
if [ -z "$REMOTE_IP" ]; then
    REMOTE_IP=$(ss -tnp | grep xrdp | grep ESTAB | awk '{print $5}' | sed -e 's/^\[::ffff://' -e 's/^\[//' -e 's/\]:.*$//')
fi


if [ -z "$REMOTE_IP" ]; then
    echo "❌ Unable to detect remote IP automatically."
    exit 1
fi

echo "✅ Detected remote IP: $REMOTE_IP"

echo "🔍 Searching for YubiKey devices on $REMOTE_IP ..."

# Save list of current hidraw devices BEFORE attach
HIDRAW_BEFORE=$(ls /dev/hidraw* 2>/dev/null)

# List available USBIP devices
USBIP_LIST=$(usbip list -r "$REMOTE_IP")

# Try to find the first matching YubiKey
BUSID=$(echo "$USBIP_LIST" | grep -i "$DEVICE_MATCH" -B 1 | grep -oP '^\s*\d+-\d+' | xargs)

if [ -z "$BUSID" ]; then
    echo "❌ No YubiKey found on remote $REMOTE_IP."
    exit 1
fi

echo "✅ Found YubiKey on BUSID: $BUSID"
echo "🔗 Attaching device..."

# Attach the device
sudo /usr/bin/usbip attach -r "$REMOTE_IP" -b "$BUSID"
sleep 1

# Save list of current hidraw devices AFTER attach
HIDRAW_AFTER=$(ls /dev/hidraw* 2>/dev/null)

# Find the newly added hidraw device(s)
NEW_HIDRAW=$(comm -13 <(echo "$HIDRAW_BEFORE" | sort) <(echo "$HIDRAW_AFTER" | sort))

if [ -z "$NEW_HIDRAW" ]; then
    echo "⚠️ Warning: No new hidraw device detected."
else
    echo "🔧 Fixing permissions on newly attached device(s):"
    for dev in $NEW_HIDRAW; do
        echo " - $dev"
        sudo /usr/bin/chmod a+rw "$dev"
    done
fi

echo "🎉 YubiKey attached and ready for use!"
