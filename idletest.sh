#!/bin/bash
# Purpose: Set automatic SSH logout for idle users

[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

IDLE_TIMEOUT=600  # 10 minutes
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup config
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

# Set or add ClientAliveInterval
if grep -q "^ClientAliveInterval" "$SSHD_CONFIG"; then
    sed -i "s/^ClientAliveInterval.*/ClientAliveInterval $IDLE_TIMEOUT/" "$SSHD_CONFIG"
else
    echo "ClientAliveInterval $IDLE_TIMEOUT" >> "$SSHD_CONFIG"
fi

# Set or add ClientAliveCountMax
if grep -q "^ClientAliveCountMax" "$SSHD_CONFIG"; then
    sed -i "s/^ClientAliveCountMax.*/ClientAliveCountMax 0/" "$SSHD_CONFIG"
else
    echo "ClientAliveCountMax 0" >> "$SSHD_CONFIG"
fi

# Restart SSH service (supports both Ubuntu + Arch)
if systemctl list-units --type=service | grep -q sshd; then
    systemctl restart sshd
else
    systemctl restart ssh
fi

echo "SSH idle timeout set to $IDLE_TIMEOUT seconds."
