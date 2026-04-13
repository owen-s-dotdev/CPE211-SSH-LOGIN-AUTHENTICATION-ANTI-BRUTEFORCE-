#!/bin/bash
# configurefail2ban.sh

# Ensuring script is run with root privileges. 
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi
# PART 1: checking if fail2ban is installed and active. 
# If it is not installed, the script updates the package list and installs fail2ban using apt. 
# If fail2ban is already installed, it simply informs the user.

# check if fail2ban is installed
if [ -z "$(command -v fail2ban-client)" ]; then
    echo "Fail2ban is not installed. Installing..."
    sudo apt update && sudo apt install -y fail2ban
else
    echo "Fail2ban is already installed."
fi

# check if fail2ban is active and running
if systemctl is-active --quiet fail2ban; then
    echo "Fail2ban is active and running."
else
    echo "Fail2ban is not active. Starting and enabling..."
    sudo systemctl enable --now fail2ban
    echo "Fail2ban has been started and enabled."
fi

# PART 2: Configuring fail2ban to protect SSH.
# Creates a local configuration file for fail2ban, which overrides the default settings. 

JAIL_LOCAL="/etc/fail2ban/jail.local"
echo "Configuring Fail2ban to protect SSH..."

# configure fail2ban to protect SSH
cat <<EOF > "$JAIL_LOCAL"
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 600
findtime = 600
EOF

# restart fail2ban to apply changes
sudo systemctl restart fail2ban
echo "Fail2ban configuration applied successfully."