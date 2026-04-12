#!/bin/bash
# whitelist.sh
# Purpose: Whitelist an IP address to prevent it from being locked out by Fail2ban.

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root or with sudo."
    exit 1
fi

read -p "Enter the IP address to whitelist: " IP_TO_WHITELIST

# Validation for empty input
if [[ -z "$IP_TO_WHITELIST" ]]; then
    echo "No IP address provided. Exiting."
    exit 1
fi

echo "Whitelisting IP: $IP_TO_WHITELIST..."

# 1. Add to a custom whitelist file
WHITELIST_FILE="/etc/ssh/ip_whitelist.txt"
if ! grep -q "$IP_TO_WHITELIST" "$WHITELIST_FILE" 2>/dev/null; then
    echo "$IP_TO_WHITELIST" >> "$WHITELIST_FILE"
    echo "Added to $WHITELIST_FILE."
else
    echo "IP is already in $WHITELIST_FILE."
fi

# 2. Add to Fail2ban ignoreip if configured
JAIL_LOCAL="/etc/fail2ban/jail.local"
if [[ -f "$JAIL_LOCAL" ]]; then
    # Check if the IP is already ignored
    if ! grep -q "^ignoreip .*$IP_TO_WHITELIST" "$JAIL_LOCAL"; then
        # Append the IP to the end of the existing ignoreip line
        sed -i "/^ignoreip/ s/$/ $IP_TO_WHITELIST/" "$JAIL_LOCAL"
        echo "Added to Fail2ban ignoreip list."
        systemctl restart fail2ban
        echo "Fail2ban service restarted to apply changes."
    else
        echo "IP is already whitelisted in Fail2ban."
    fi
else
    echo "Fail2ban jail.local not found. Skipping Fail2ban configuration."
fi

# 3. Add an iptables ACCEPT rule to override any potential DROP rules
if ! iptables -C INPUT -s "$IP_TO_WHITELIST" -j ACCEPT 2>/dev/null; then
    iptables -I INPUT 1 -s "$IP_TO_WHITELIST" -j ACCEPT
    echo "Added high-priority iptables ACCEPT rule for $IP_TO_WHITELIST."
else
    echo "iptables ACCEPT rule already exists for this IP."
fi

echo "Whitelisting $IP_TO_WHITELIST complete."