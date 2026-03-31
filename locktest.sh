#!/bin/bash
# Purp: Lock user accounts after multiple failed SSH login attempts

FAIL_LIMIT=3
LOCK_TIME=600
PAM_FILE="/etc/pam.d/sshd"

# Add faillock rules only if not already present
if ! grep -q "pam_faillock.so" "$PAM_FILE"; then
    cat <<EOL >> "$PAM_FILE"
auth required pam_faillock.so preauth silent deny=$FAIL_LIMIT unlock_time=$LOCK_TIME
auth [success=1 default=bad] pam_unix.so
auth [default=die] pam_faillock.so authfail deny=$FAIL_LIMIT unlock_time=$LOCK_TIME
account required pam_faillock.so
EOL
fi

echo "Accounts will be locked after $FAIL_LIMIT failed attempts for $LOCK_TIME seconds."
