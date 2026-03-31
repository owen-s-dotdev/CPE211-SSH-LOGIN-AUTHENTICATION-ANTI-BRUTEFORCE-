#!bin/bash

# sudo apt update && sudo apt install fail2ban
# sudo systemctl start fail2ban
# sudo systemctl enable fail2ban
# sudo systemctl status fail2ban

# PART 1: checking if fail2ban is installed on the system. 
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