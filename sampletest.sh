#!bin/bash

# sudo apt update && sudo apt install fail2ban
# sudo systemctl start fail2ban
# sudo systemctl enable fail2ban

if sudo systemctl status fail2ban; then
    echo "Fail2ban is running."
else
    echo "Fail2ban is not running."
fi
