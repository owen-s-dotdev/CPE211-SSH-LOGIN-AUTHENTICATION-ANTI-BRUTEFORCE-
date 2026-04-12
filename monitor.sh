#!/bin/bash

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
