#!/bin/bash

# === CONFIG ===
DEVICE_MATCH="Yubico"     # Match devices containing "Yubico"
# ===============

PORTS_TO_DETACH=()
CURRENT_PORT=""

echo "🔍 Searching for attached USBIP YubiKey..."
ATTACHED=$(usbip port)

# Extract port of attached devices matching the DEVICE_MATCH string
while IFS= read -r line; do
    if [[ "$line" =~ ^Port\ ([0-9]+): ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"
    elif echo "$line" | grep -qi "$DEVICE_MATCH"; then
        if [[ -n "$CURRENT_PORT" ]]; then
            PORTS_TO_DETACH+=("$CURRENT_PORT")
        fi
    fi
done <<< "$ATTACHED"

if [ "${#PORTS_TO_DETACH[@]}" -eq 0 ]; then
    echo "❌ No YubiKey device currently attached via usbip."
    exit 0
fi

# Detach each matching port
for PORT in "$PORTS_TO_DETACH"; do
    echo "🔌 Detaching YubiKey from Port $PORT..."
    sudo /usr/bin/usbip detach -p "$PORT"
done

echo "✅ Detach complete."
