#!/bin/bash
# Purpose: Lock user accounts after multiple failed SSH login attempts

[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

FAIL_LIMIT=3
LOCK_TIME=600
PAM_FILE="/etc/pam.d/sshd"

# Backup PAM config
cp "$PAM_FILE" "${PAM_FILE}.bak"

# Add faillock rules safely (only if missing)

grep -q "pam_faillock.so preauth" "$PAM_FILE" || \
sed -i "1i auth required pam_faillock.so preauth silent deny=$FAIL_LIMIT unlock_time=$LOCK_TIME" "$PAM_FILE"

grep -q "pam_faillock.so authfail" "$PAM_FILE" || \
sed -i "/pam_unix.so/a auth [default=die] pam_faillock.so authfail deny=$FAIL_LIMIT unlock_time=$LOCK_TIME" "$PAM_FILE"

grep -q "account required pam_faillock.so" "$PAM_FILE" || \
echo "account required pam_faillock.so" >> "$PAM_FILE"

echo "Accounts will be locked after $FAIL_LIMIT failed attempts for $LOCK_TIME seconds."
