#!/bin/bash

WHITELIST_FILE="/etc/ssh/ip_whitelist.txt"

init_file() {
    [ ! -f "$WHITELIST_FILE" ] && touch "$WHITELIST_FILE"
    chmod 600 "$WHITELIST_FILE"
}

add_ip() {
    read -p "Enter IP to whitelist: " ip
    if ! grep -qx "$ip" "$WHITELIST_FILE"; then
        echo "$ip" >> "$WHITELIST_FILE"
        iptables -I INPUT 1 -s "$ip" -j ACCEPT
        echo "Whitelisted: $ip"
    else
        echo "Already whitelisted."
    fi
}

remove_ip() {
    read -p "Enter IP to remove: " ip
    sed -i "/^$ip$/d" "$WHITELIST_FILE"
    iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null
    echo "Removed: $ip"
}

view_ips() {
    echo "=== Whitelist ==="
    cat "$WHITELIST_FILE"
}

init_file

while true; do
    echo ""
    echo "=== UBUNTU WHITELIST MENU ==="
    echo "1. Add IP"
    echo "2. Remove IP"
    echo "3. View"
    echo "4. Exit"
    read -p "Choose: " c

    case $c in
        1) add_ip ;;
        2) remove_ip ;;
        3) view_ips ;;
        4) exit ;;
    esac
done


#strickly done in arch linux, idk if this script would work in ubuntu. triny ko baguhin ung script para gumana sa ubuntu pero
#unknown pa kung gagana. it's working on my end nmn.