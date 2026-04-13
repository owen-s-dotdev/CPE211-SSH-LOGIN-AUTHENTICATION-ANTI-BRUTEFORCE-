#!/bin/bash

# 1. Verify root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This master script must be run as root or with sudo."
    exit 1
fi

LOG_FILE="/var/log/auth.log"

echo "- SSH Monitoring Report -"

# counts failed login attempts per IP
echo ""
echo "Failed Login Attempts per IP:"
grep "Failed password" $LOG_FILE | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr

# shows invalid users
echo ""
echo "Invalid User Attempts:"
grep "Invalid user" $LOG_FILE

# (incomplete) ^ only shows the failed login attempts as well as invalid users, 
# will further improve by showing status such as if an ip is blocked as well as whitelisted ips
