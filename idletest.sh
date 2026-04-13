#!/bin/bash
# Purpose: Set automatic SSH logout for idle users

# 1. Verify root privileges
[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

IDLE_TIMEOUT=600  # 10 minutes

# Backup sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Update or add settings
sed -i "/^ClientAliveInterval/c\ClientAliveInterval $IDLE_TIMEOUT" /etc/ssh/sshd_config || \
    echo "ClientAliveInterval $IDLE_TIMEOUT" >> /etc/ssh/sshd_config

sed -i "/^ClientAliveCountMax/c\ClientAliveCountMax 0" /etc/ssh/sshd_config || \
    echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# Apply changes
systemctl restart sshd

echo "SSH idle timeout set to $IDLE_TIMEOUT seconds."
