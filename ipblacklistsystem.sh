#!/bin/bash

# IP Blacklist System Script, this blocks the attacker's IP addresses based on failed SSH login attempts

LOG_FILE="/var/log/auth.log"
BLACKLIST_FILE="/etc/ssh/ip_blacklist.txt"

# Ensure blacklist file exists
if [ ! -f "$BLACKLIST_FILE" ]; then
    sudo touch "$BLACKLIST_FILE"
    sudo chmod 600 "$BLACKLIST_FILE"
fi

# Function: Extract failed SSH login IPs
extract_failed_ips() {
    grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
}

# Function: Block IP using iptables
block_ip() {
    local ip=$1
    if ! grep -q "$ip" "$BLACKLIST_FILE"; then
        echo "Blocking IP: $ip"
        sudo iptables -A INPUT -s "$ip" -j DROP
        echo "$ip" | sudo tee -a "$BLACKLIST_FILE" > /dev/null
    else
        echo "IP $ip is already blacklisted."
    fi
}

# Main Execution
echo "Scanning for failed SSH login attempts..."
FAILED_IPS=$(extract_failed_ips)

echo "Suspicious IPs detected:"
echo "$FAILED_IPS"

# Block IPs with more than 5 failed attempts
echo "$FAILED_IPS" | while read -r count ip; do
    if [ "$count" -gt 5 ]; then
        block_ip "$ip"
    fi
done

echo "Blacklist update complete."

# All of these are just drafts and are created in github. will be testing it in linux terminal later.
