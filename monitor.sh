#!/bin/bash

LOG_FILE="/var/log/auth.log"
BLACKLIST="/etc/ssh/ip_blacklist.txt"
WHITELIST="/etc/ssh/ip_whitelist.txt"

echo "SSH SECURITY MONITORING REPORT"

# SUMMARY
echo ""
echo "SUMMARY"
echo "Total Failed Attempts: $(grep -a -c 'Failed password' $LOG_FILE 2>/dev/null)"
echo "Total Invalid Users: $(grep -a -c 'Invalid user' $LOG_FILE 2>/dev/null)"

# FAILED LOGIN ATTEMPTS
echo ""
echo "FAILED LOGIN ATTEMPTS PER IP"

FAILED=$(grep -a "Failed password" $LOG_FILE 2>/dev/null)

if [ -z "$FAILED" ]; then
    echo "No failed login attempts found."
else
    echo "$FAILED" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | while read count ip
    do
        status=""

        # Whitelist should override block
        if grep -q "$ip" "$WHITELIST" 2>/dev/null; then
            status="[WHITELISTED]"
        elif grep -q "$ip" "$BLACKLIST" 2>/dev/null; then
            status="[BLOCKED]"
        fi

        echo "$count $ip $status"
    done
fi

# INVALID USERS
echo ""
echo "INVALID USER ATTEMPTS"
grep -a "Invalid user" $LOG_FILE 2>/dev/null || echo "No invalid user attempts found."

# BLOCKED IPS
echo ""
echo "BLOCKED IPS"
if [ -f "$BLACKLIST" ] && [ -s "$BLACKLIST" ]; then
    cat "$BLACKLIST"
else
    echo "No blocked IPs."
fi

# WHITELISTED IPS
echo ""
echo "WHITELISTED IPS"
if [ -f "$WHITELIST" ] && [ -s "$WHITELIST" ]; then
    cat "$WHITELIST"
else
    echo "No whitelisted IPs."
fi

# FAIL2BAN STATUS
echo ""
echo "FAIL2BAN STATUS"
sudo fail2ban-client status sshd 2>/dev/null || echo "Fail2Ban not running or not configured."

echo ""
echo "END OF REPORT"

# This script shows summary of failed attempts and invalid users, failed login attempts, invalid users, blocked ips, whitelisted ips, status of fail2ban.
