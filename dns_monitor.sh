#!/bin/bash

[[ "$EUID" -ne 0 ]] && { echo "Please run as root (sudo ./dns_monitor.sh)"; exit 1; }

REFRESH_RATE=3
ACTIVITY_TIMEOUT=30
STATS_FILE="/tmp/dns_clients.log"
ACTIVE_CLIENTS="/tmp/dns_active_clients.txt"
BLOCKED_FILE="/tmp/blocked_ips.txt"
HOST_IP="192.168.0.209"

touch "$STATS_FILE" "$ACTIVE_CLIENTS" "$BLOCKED_FILE"

cleanup() {
    clear
    echo -e "\e[33m[*] Shutting down DNS monitor...\e[0m"
    pkill -f "tcpdump.*port 53" 2>/dev/null
    rm -f "$STATS_FILE" "$ACTIVE_CLIENTS"
    echo -e "\e[32m[✓] Monitor stopped successfully.\e[0m"
    exit 0
}
trap cleanup EXIT INT TERM

block_ip() {
    read -p "Enter IP to block: " ip
    [[ -z "$ip" ]] && return
    
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        ufw deny from "$ip" to any port 53 >/dev/null 2>&1
        echo "$ip" >> "$BLOCKED_FILE"
        echo -e "\e[31m[!] IP $ip blocked from DNS access\e[0m"
        sleep 2
    else
        echo -e "\e[31m[!] Invalid IP format\e[0m"
        sleep 1
    fi
}

unblock_ip() {
    read -p "Enter IP to unblock: " ip
    [[ -z "$ip" ]] && return
    
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        ufw delete deny from "$ip" to any port 53 >/dev/null 2>&1
        sed -i "/$ip/d" "$BLOCKED_FILE" 2>/dev/null
        echo -e "\e[32m[✓] IP $ip unblocked\e[0m"
        sleep 2
    else
        echo -e "\e[31m[!] Invalid IP format\e[0m"
        sleep 1
    fi
}

view_stats() {
    clear
    echo -e "\e[36m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[36m║\e[0m                  \e[1mDNS USAGE STATISTICS\e[0m                    \e[36m║\e[0m"
    echo -e "\e[36m╚════════════════════════════════════════════════════════════╝\e[0m"
    echo ""
    
    echo -e "\e[1mTop 10 Active Clients:\e[0m"
    awk '{print $1}' "$STATS_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -10 | \
        awk '{printf "  %3d queries - %s\n", $1, $2}'
    
    echo ""
    echo -e "\e[1mBlocked IPs:\e[0m"
    if [[ -s "$BLOCKED_FILE" ]]; then
        cat "$BLOCKED_FILE" | while read ip; do echo "  • $ip"; done
    else
        echo "  None"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

> "$STATS_FILE"
> "$ACTIVE_CLIENTS"

tcpdump -l -n -i any port 53 2>/dev/null | while read line; do
    if echo "$line" | grep -qE '\? [A-Za-z]'; then
        CLIENT_IP=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        SITE=$(echo "$line" | grep -oE '\? [^ ]+' | cut -d' ' -f2 | sed 's/\.$//')
        
        if [[ -n "$CLIENT_IP" && "$CLIENT_IP" != "127.0.0.1" && "$CLIENT_IP" != "$HOST_IP" ]]; then
            TIMESTAMP=$(date +%s)
            echo "$CLIENT_IP $SITE" >> "$STATS_FILE"
            
            grep -v "^$CLIENT_IP " "$ACTIVE_CLIENTS" 2>/dev/null > "$ACTIVE_CLIENTS.tmp"
            echo "$CLIENT_IP $TIMESTAMP" >> "$ACTIVE_CLIENTS.tmp"
            mv "$ACTIVE_CLIENTS.tmp" "$ACTIVE_CLIENTS"
        fi
    fi
done &

while true; do
    clear
    echo -e "\e[36m╔════════════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[36m║\e[0m              \e[1mLIVE DNS CLIENT MONITOR\e[0m                    \e[36m║\e[0m"
    echo -e "\e[36m╚════════════════════════════════════════════════════════════╝\e[0m"
    echo ""
    
    if [[ $(systemctl is-active bind9) == "active" ]]; then
        echo -e "  \e[32m●\e[0m DNS Status: \e[1;32mONLINE\e[0m"
        echo -e "  \e[34m●\e[0m Uptime: $(ps -eo comm,etime | awk '/named/{print $2}')"
    else
        echo -e "  \e[31m●\e[0m DNS Status: \e[1;31mOFFLINE\e[0m"
    fi
    
    echo -e "  \e[34m●\e[0m Time: $(date '+%H:%M:%S')"
    echo ""
    
    CURRENT_TIME=$(date +%s)
    > "$ACTIVE_CLIENTS.tmp"
    
    if [[ -s "$ACTIVE_CLIENTS" ]]; then
        while read ip timestamp; do
            TIME_DIFF=$((CURRENT_TIME - timestamp))
            [[ $TIME_DIFF -le $ACTIVITY_TIMEOUT ]] && echo "$ip $timestamp" >> "$ACTIVE_CLIENTS.tmp"
        done < "$ACTIVE_CLIENTS"
        mv "$ACTIVE_CLIENTS.tmp" "$ACTIVE_CLIENTS"
    fi
    
    echo -e "\e[1m╔══ ACTIVE CLIENTS (Last ${ACTIVITY_TIMEOUT}s) ═══════════════════════════╗\e[0m"
    
    if [[ -s "$ACTIVE_CLIENTS" ]]; then
        while read ip timestamp; do
            TIME_AGO=$((CURRENT_TIME - timestamp))
            
            if grep -q "^$ip$" "$BLOCKED_FILE" 2>/dev/null; then
                printf "  \e[31m[BLOCKED]\e[0m %-16s (inactive for %ds)\n" "$ip" "$TIME_AGO"
            else
                printf "  \e[32m[ACTIVE]\e[0m  %-16s (last query %ds ago)\n" "$ip" "$TIME_AGO"
            fi
        done < "$ACTIVE_CLIENTS"
        
        ACTIVE_COUNT=$(wc -l < "$ACTIVE_CLIENTS")
        TOTAL_CLIENTS=$(awk '{print $1}' "$STATS_FILE" | sort -u | wc -l)
        TOTAL_QUERIES=$(wc -l < "$STATS_FILE")
        ACTIVE_COUNT=$(wc -l < "$ACTIVE_CLIENTS")
        TOTAL_CLIENTS=$(awk '{print $1}' "$STATS_FILE" | sort -u | wc -l)
        TOTAL_QUERIES=$(wc -l < "$STATS_FILE")
        
        echo -e "\e[1m╚═════════════════════════════════════════════════════════════╝\e[0m"
        echo ""
        echo -e "  Currently Active: \e[1;32m$ACTIVE_COUNT\e[0m"
        echo -e "  Total Unique Clients (All Time): \e[1;33m$TOTAL_CLIENTS\e[0m"
        echo -e "  Total Queries (All Time): \e[1;33m$TOTAL_QUERIES\e[0m"
    else
        echo -e "  \e[90mWaiting for DNS queries...\e[0m"
        echo -e "\e[1m╚═════════════════════════════════════════════════════════════╝\e[0m"
        echo ""
        echo -e "  Currently Active: \e[1;32m0\e[0m"
    fi
    
    echo ""
    echo -e "\e[90m───────────────────────────────────────────────────────────────\e[0m"
    echo -e "  [\e[1mb\e[0m] Block IP  [\e[1mu\e[0m] Unblock IP  [\e[1ms\e[0m] Statistics  [\e[1mq\e[0m] Quit"
    echo -e "\e[90m───────────────────────────────────────────────────────────────\e[0m"
    
    read -t $REFRESH_RATE -n 1 -s key
    case "$key" in
        b) block_ip ;;
        u) unblock_ip ;;
        s) view_stats ;;
        q) cleanup ;;
    esac
done