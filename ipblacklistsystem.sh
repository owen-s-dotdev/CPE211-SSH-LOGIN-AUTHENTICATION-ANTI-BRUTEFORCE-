#!/bin/bash

LOG_FILE="/var/log/auth.log"
BLACKLIST_FILE="/etc/ssh/ip_blacklist.txt"

init_file() {
    [ ! -f "$BLACKLIST_FILE" ] && touch "$BLACKLIST_FILE"
    chmod 600 "$BLACKLIST_FILE"
}

add_ip() {
    read -p "Enter IP to blacklist: " ip
    if ! grep -qx "$ip" "$BLACKLIST_FILE"; then
        echo "$ip" >> "$BLACKLIST_FILE"
        iptables -A INPUT -s "$ip" -j DROP
        echo "Blacklisted: $ip"
    else
        echo "Already blacklisted."
    fi
}

remove_ip() {
    read -p "Enter IP to remove: " ip
    sed -i "/^$ip$/d" "$BLACKLIST_FILE"
    iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
    echo "Removed: $ip"
}

view_ips() {
    echo "=== Blacklist ==="
    cat "$BLACKLIST_FILE"
}

auto_block() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "auth.log not found. Ubuntu/Debian only."
        return
    fi

    grep "Failed password" "$LOG_FILE" | awk '{print $(NF-3)}' | \
    sort | uniq -c | sort -nr | while read count ip; do

        [[ -z "$count" || -z "$ip" ]] && continue

        if [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -gt 5 ]; then
            if ! grep -qx "$ip" "$BLACKLIST_FILE"; then
                echo "$ip" >> "$BLACKLIST_FILE"
                iptables -A INPUT -s "$ip" -j DROP
                echo "Auto-blocked: $ip"
            fi
        fi
    done
}

init_file

while true; do
    echo ""
    echo "=== UBUNTU BLACKLIST MENU ==="
    echo "1. Auto blacklist"
    echo "2. Add IP"
    echo "3. Remove IP"
    echo "4. View"
    echo "5. Exit"
    read -p "Choose: " c

    case $c in
        1) auto_block ;;
        2) add_ip ;;
        3) remove_ip ;;
        4) view_ips ;;
        5) exit ;;
    esac
done


#strickly done in arch linux, idk if this script would work in ubuntu. triny ko baguhin ung script para gumana sa ubuntu pero
#unknown pa kung gagana. it's working on my end nmn
