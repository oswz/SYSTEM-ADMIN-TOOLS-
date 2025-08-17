#!/bin/bash

show_menu() {
    echo "┌─────────────────────────────────────────┐"
    echo "│         SYSTEM ADMIN TOOLS v1.0         │"
    echo "│               made by AA                │"
    echo "└─────────────────────────────────────────┘"
    echo
    echo "1) User Management"
    echo "2) System Health Check"
    echo "3) Backup Tool"
    echo "4) Log Scanner"
    echo "5) Network Info"
    echo "6) Exit"
    echo "================================="
    echo -n "Choose option [1-6]: "
}

user_management() {
    echo "┌─────────────────────────────────────────┐"
    echo "│            USER MANAGEMENT              │"
    echo "└─────────────────────────────────────────┘"
    echo "1) Add User"
    echo "2) Remove User"
    echo "3) List Users"
    echo "4) Set Password"
    echo "5) Assign Groups"
    echo "6) User Information"
    echo "7) Back to Main Menu"
    echo "─────────────────────────────────────────"
    echo -n "Choose option [1-7]: "
    read user_choice
    
    case $user_choice in
        1)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│              ADD NEW USER               │"
            echo "└─────────────────────────────────────────┘"
            echo -n "Enter username: "
            read username
            
            if id "$username" &>/dev/null; then
                printf "\033[31mError: User '%s' already exists!\033[0m\n" "$username"
            else
                echo -n "Create home directory? [Y/n]: "
                read create_home
                
                if [ "$create_home" = "n" ] || [ "$create_home" = "N" ]; then
                    sudo useradd "$username"
                else
                    sudo useradd -m "$username"
                fi
                
                if [ $? -eq 0 ]; then
                    printf "\033[32mUser '%s' created successfully!\033[0m\n" "$username"
                    echo -n "Set password now? [Y/n]: "
                    read set_pass
                    if [ "$set_pass" != "n" ] && [ "$set_pass" != "N" ]; then
                        sudo passwd "$username"
                    fi
                else
                    printf "\033[31mFailed to create user '%s'\033[0m\n" "$username"
                fi
            fi
            ;;
        2)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│             REMOVE USER                 │"
            echo "└─────────────────────────────────────────┘"
            echo -n "Enter username to remove: "
            read username
            
            if ! id "$username" &>/dev/null; then
                printf "\033[31mError: User '%s' does not exist!\033[0m\n" "$username"
            else
                echo
                printf "\033[33mWARNING: This will permanently delete user '%s'\033[0m\n" "$username"
                echo -n "Remove home directory too? [y/N]: "
                read remove_home
                echo -n "Are you sure? [y/N]: "
                read confirm
                
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    if [ "$remove_home" = "y" ] || [ "$remove_home" = "Y" ]; then
                        sudo userdel -r "$username"
                    else
                        sudo userdel "$username"
                    fi
                    
                    if [ $? -eq 0 ]; then
                        printf "\033[32mUser '%s' removed successfully!\033[0m\n" "$username"
                    else
                        printf "\033[31mFailed to remove user '%s'\033[0m\n" "$username"
                    fi
                else
                    echo "Operation cancelled"
                fi
            fi
            ;;
        3)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│             SYSTEM USERS                │"
            echo "└─────────────────────────────────────────┘"
            echo "Regular Users (UID ≥ 1000):"
            echo "────────────────────────────────────────"
            printf "%-15s %-8s %-20s %-s\n" "USERNAME" "UID" "HOME" "SHELL"
            awk -F: '$3>=1000 {printf "%-15s %-8s %-20s %-s\n", $1, $3, $6, $7}' /etc/passwd
            
            echo
            echo "System Users (UID < 1000):"
            echo "────────────────────────────────────────"
            printf "%-15s %-8s %-s\n" "USERNAME" "UID" "DESCRIPTION"
            awk -F: '$3<1000 {printf "%-15s %-8s %-s\n", $1, $3, $5}' /etc/passwd | head -10
            
            echo
            user_count=$(awk -F: '$3>=1000' /etc/passwd | wc -l)
            printf "Total regular users: \033[32m%d\033[0m\n" "$user_count"
            ;;
        4)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│            SET PASSWORD                 │"
            echo "└─────────────────────────────────────────┘"
            echo -n "Enter username: "
            read username
            
            if ! id "$username" &>/dev/null; then
                printf "\033[31mError: User '%s' does not exist!\033[0m\n" "$username"
            else
                printf "Setting password for user: \033[33m%s\033[0m\n" "$username"
                sudo passwd "$username"
                if [ $? -eq 0 ]; then
                    printf "\033[32mPassword updated successfully!\033[0m\n"
                fi
            fi
            ;;
        5)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│            ASSIGN GROUPS                │"
            echo "└─────────────────────────────────────────┘"
            echo -n "Enter username: "
            read username
            
            if ! id "$username" &>/dev/null; then
                printf "\033[31mError: User '%s' does not exist!\033[0m\n" "$username"
            else
                echo
                printf "Current groups for \033[33m%s\033[0m: " "$username"
                groups "$username" | cut -d: -f2
                echo
                echo "Available groups:"
                echo "────────────────────────────────────────"
                cut -d: -f1 /etc/group | sort | column -c 60
                echo
                echo -n "Enter group name to add user to: "
                read groupname
                
                if ! getent group "$groupname" >/dev/null; then
                    printf "\033[31mError: Group '%s' does not exist!\033[0m\n" "$groupname"
                    echo -n "Create group? [y/N]: "
                    read create_group
                    if [ "$create_group" = "y" ] || [ "$create_group" = "Y" ]; then
                        sudo groupadd "$groupname"
                        printf "\033[32mGroup '%s' created!\033[0m\n" "$groupname"
                    else
                        echo "Operation cancelled"
                        echo
                        read -p "Press Enter to continue..."
                        return
                    fi
                fi
                
                sudo usermod -aG "$groupname" "$username"
                if [ $? -eq 0 ]; then
                    printf "\033[32mUser '%s' added to group '%s'\033[0m\n" "$username" "$groupname"
                    echo
                    printf "Updated groups for \033[33m%s\033[0m: " "$username"
                    groups "$username" | cut -d: -f2
                else
                    printf "\033[31mFailed to add user to group\033[0m\n"
                fi
            fi
            ;;
        6)
            echo
            echo "┌─────────────────────────────────────────┐"
            echo "│           USER INFORMATION              │"
            echo "└─────────────────────────────────────────┘"
            echo -n "Enter username: "
            read username
            
            if ! id "$username" &>/dev/null; then
                printf "\033[31mError: User '%s' does not exist!\033[0m\n" "$username"
            else
                echo
                printf "Information for user: \033[33m%s\033[0m\n" "$username"
                echo "────────────────────────────────────────"
                
                user_info=$(getent passwd "$username")
                IFS=':' read -r uname x uid gid gecos home shell <<< "$user_info"
                
                printf "User ID (UID):    %s\n" "$uid"
                printf "Group ID (GID):   %s\n" "$gid"
                printf "Home Directory:   %s\n" "$home"
                printf "Shell:            %s\n" "$shell"
                printf "Full Name:        %s\n" "${gecos:-Not set}"
                
                echo
                printf "Group Memberships: "
                groups "$username" | cut -d: -f2
                
                echo
                if [ -d "$home" ]; then
                    printf "Home Dir Size:    %s\n" "$(du -sh "$home" 2>/dev/null | cut -f1)"
                    printf "Last Login:       "
                    last -1 "$username" | head -1 | awk '{print $3, $4, $5, $6}' | grep -v "^$" || echo "Never"
                else
                    printf "\033[33mHome directory does not exist\033[0m\n"
                fi
                
                echo
                printf "Account Status:   "
                if passwd -S "$username" 2>/dev/null | grep -q "P"; then
                    printf "\033[32mActive\033[0m\n"
                else
                    printf "\033[31mLocked/Disabled\033[0m\n"
                fi
            fi
            ;;
        7)
            return
            ;;
        *)
            printf "\033[31mInvalid option!\033[0m\n"
            ;;
    esac
    echo
    read -p "Press Enter to continue..."
}


system_health() {
    echo "┌─────────────────────────────────────────┐"
    echo "│           SYSTEM HEALTH CHECK           │"
    echo "└─────────────────────────────────────────┘"
    echo

    printf "%-15s" "|CPU Usage|"
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    printf "%.1f%%\n" "$cpu_usage"
    
    printf "%-15s" "|RAM Usage|"
    free -h | awk 'NR==2{printf "%s/%s (%.1f%%)\n", $3,$2,$3*100/$2}'
    
    printf "%-15s" "|Disk Usage|"
    df -h | awk '$NF=="/"{printf "%s/%s (%s)\n", $3,$2,$5}'
    
    echo
    echo "|Top 5 Processes by CPU Usage|"
    echo "────────────────────────────────────────"
    ps aux --sort=-%cpu | awk 'NR==1{printf "%-12s %-8s %-8s %-s\n", "USER", "PID", "%CPU", "COMMAND"} NR>=2&&NR<=6{printf "%-12s %-8s %-8s %-s\n", $1, $2, $3, $11}'
    
    echo
    echo "|Top 5 Processes by Memory Usage|"
    echo "────────────────────────────────────────"
    ps aux --sort=-%mem | awk 'NR==1{printf "%-12s %-8s %-8s %-s\n", "USER", "PID", "%MEM", "COMMAND"} NR>=2&&NR<=6{printf "%-12s %-8s %-8s %-s\n", $1, $2, $4, $11}'
    
    echo
    echo "|System Uptime|"
    uptime | awk '{print $3,$4}' | sed 's/,//'
    
    echo
    printf "\033[32m✓ Health check complete!\033[0m\n"
    echo
    read -p "Press Enter to continue..."
}

backup_tool() {
    echo "┌─────────────────────────────────────────┐"
    echo "│             BACKUP TOOL                 │"
    echo "└─────────────────────────────────────────┘"
    echo
    echo -n "Enter folder path to backup: "
    read folder_path
    
    if [ ! -d "$folder_path" ]; then
        echo "Error: Folder does not exist!"
        read -p "Press Enter to continue..."
        return
    fi
    
    sudo mkdir -p /backups
    timestamp=$(date +%Y%m%d_%H%M%S)
    folder_name=$(basename "$folder_path")
    backup_name="${folder_name}_backup_${timestamp}.tar.gz"
    
    echo "Creating backup..."
    sudo tar -czf "/backups/$backup_name" -C "$(dirname "$folder_path")" "$folder_name"
    
    if [ $? -eq 0 ]; then
        echo "Backup created successfully: /backups/$backup_name"
        echo "Backup size: $(du -h "/backups/$backup_name" | cut -f1)"
    else
        echo "Backup failed!"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

log_scanner() {
    echo "┌─────────────────────────────────────────┐"
    echo "│              LOG SCANNER                │"
    echo "└─────────────────────────────────────────┘"
    echo
    
    if [ ! -f /var/log/auth.log ]; then
        printf "\033[31mError: /var/log/auth.log not found!\033[0m\n"
        echo
        read -p "Press Enter to continue..."
        return
    fi
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    report_file="/tmp/failed_logins_${timestamp}.txt"
    
    echo "Scanning authentication logs..."
    echo "────────────────────────────────────────"
    
    echo "┌─────────────────────────────────────────────────────────┐" > "$report_file"
    echo "│                  FAILED LOGIN REPORT                    │" >> "$report_file"
    echo "│                Generated: $(date)                │" >> "$report_file"
    echo "└─────────────────────────────────────────────────────────┘" >> "$report_file"
    echo >> "$report_file"
    
    echo "SUMMARY:" >> "$report_file"
    echo "────────────────────────────────────────" >> "$report_file"
    
    failed_pass=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || echo "0")
    auth_fail=$(grep -c "authentication failure" /var/log/auth.log 2>/dev/null || echo "0")
    invalid_user=$(grep -c "Invalid user" /var/log/auth.log 2>/dev/null || echo "0")
    
    # Ensure variables are numeric (remove any whitespace/newlines)
    failed_pass=${failed_pass:-0}
    auth_fail=${auth_fail:-0}
    invalid_user=${invalid_user:-0}
    
    # Strip any non-numeric characters and ensure they're valid numbers
    failed_pass=$(echo "$failed_pass" | tr -cd '0-9' || echo "0")
    auth_fail=$(echo "$auth_fail" | tr -cd '0-9' || echo "0")
    invalid_user=$(echo "$invalid_user" | tr -cd '0-9' || echo "0")
    
    # Set to 0 if empty
    failed_pass=${failed_pass:-0}
    auth_fail=${auth_fail:-0}
    invalid_user=${invalid_user:-0}
    
    total_failed=$((failed_pass + auth_fail + invalid_user))
    
    printf "Failed Password Attempts: %d\n" "$failed_pass" >> "$report_file"
    printf "Authentication Failures: %d\n" "$auth_fail" >> "$report_file"
    printf "Invalid User Attempts: %d\n" "$invalid_user" >> "$report_file"
    printf "Total Failed Attempts: %d\n" "$total_failed" >> "$report_file"
    echo >> "$report_file"
    
    echo "Recent Failed Login Attempts (Last 50):" >> "$report_file"
    echo "────────────────────────────────────────────────────────────────" >> "$report_file"
    (grep "Failed password\|authentication failure\|Invalid user" /var/log/auth.log | tail -50) >> "$report_file"
    echo >> "$report_file"
    
    echo "Top Failed Login IPs:" >> "$report_file"
    echo "────────────────────────────────────────" >> "$report_file"
    grep "Failed password\|authentication failure" /var/log/auth.log | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | sort -nr | head -10 >> "$report_file"
    echo >> "$report_file"
    
    echo "Top Failed Usernames:" >> "$report_file"
    echo "────────────────────────────────────────" >> "$report_file"
    grep "Failed password" /var/log/auth.log | awk '{for(i=1;i<=NF;i++) if($i=="user") print $(i+1)}' | sort | uniq -c | sort -nr | head -10 >> "$report_file"
    
    echo "Scan Results:"
    echo "────────────────────────────────────────"
    printf "Failed Password Attempts: \033[31m%d\033[0m\n" "$failed_pass"
    printf "Authentication Failures: \033[31m%d\033[0m\n" "$auth_fail"
    printf "Invalid User Attempts: \033[31m%d\033[0m\n" "$invalid_user"
    printf "Total Failed Attempts: \033[33m%d\033[0m\n" "$total_failed"
    echo
    
    printf "Report saved to: \033[32m%s\033[0m\n" "$report_file"
    echo " File size: $(du -h "$report_file" | cut -f1)"
    
    if [ "$total_failed" -gt 100 ]; then
        printf "\n\033[31mWARNING: High number of failed login attempts detected!\033[0m\n"
    elif [ "$total_failed" -gt 50 ]; then
        printf "\n\033[33mCAUTION: Moderate failed login activity detected!\033[0m\n"
    else
        printf "\n\033[32mNormal login activity levels\033[0m\n"
    fi
    
    echo
    echo -n "View detailed report? [y/N]: "
    read view_choice
    if [ "$view_choice" = "y" ] || [ "$view_choice" = "Y" ]; then
        clear
        less "$report_file"
    fi
    
    echo
    printf "\033[32mLog scan complete!\033[0m\n"
    echo
    read -p "Press Enter to continue..."
}


network_info() {
    echo "┌─────────────────────────────────────────┐"
    echo "│             NETWORK INFO                │"
    echo "└─────────────────────────────────────────┘"
    echo
    echo "|Network Interfaces & IP Addresses|"
    echo "────────────────────────────────────────"
    ip addr show | awk '/^[0-9]+:/ {iface=$2; gsub(/:/, "", iface)} /inet / && !/127.0.0.1/ {printf "%-12s %s\n", iface, $2}'
    
    echo
    echo "|Listening Ports (Top 10)|"
    echo "────────────────────────────────────────"
    printf "%-8s %-15s %-8s %-s\n" "PROTO" "ADDRESS" "PORT" "STATE"
    netstat -tuln | grep LISTEN | head -10 | awk '{
        proto = ($1 == "tcp") ? "TCP" : "UDP"
        split($4, addr, ":")
        port = addr[length(addr)]
        address = substr($4, 1, length($4)-length(port)-1)
        if(address == "") address = "0.0.0.0"
        printf "%-8s %-15s %-8s %-s\n", proto, address, port, "LISTEN"
    }'
    
    echo
    echo "|Active Connections (Top 10)|"
    echo "────────────────────────────────────────"
    printf "%-8s %-22s %-22s %-s\n" "PROTO" "LOCAL ADDRESS" "REMOTE ADDRESS" "STATE"
    netstat -an | grep ESTABLISHED | head -10 | awk '{
        proto = ($1 == "tcp") ? "TCP" : "UDP"
        printf "%-8s %-22s %-22s %-s\n", proto, $4, $5, $6
    }'
    
    echo
    echo "|Network Interface Statistics|"
    echo "────────────────────────────────────────"
    printf "%-12s %-15s %-15s\n" "INTERFACE" "RX (Bytes)" "TX (Bytes)"
    cat /proc/net/dev | awk 'NR>2 {
        iface = $1
        gsub(/:/, "", iface)
        rx = $2
        tx = $10
        if(rx > 1024*1024*1024) rx_formatted = sprintf("%.2f GB", rx/(1024*1024*1024))
        else if(rx > 1024*1024) rx_formatted = sprintf("%.2f MB", rx/(1024*1024))
        else if(rx > 1024) rx_formatted = sprintf("%.2f KB", rx/1024)
        else rx_formatted = rx " B"
        
        if(tx > 1024*1024*1024) tx_formatted = sprintf("%.2f GB", tx/(1024*1024*1024))
        else if(tx > 1024*1024) tx_formatted = sprintf("%.2f MB", tx/(1024*1024))
        else if(tx > 1024) tx_formatted = sprintf("%.2f KB", tx/1024)
        else tx_formatted = tx " B"
        
        printf "%-12s %-15s %-15s\n", iface, rx_formatted, tx_formatted
    }'
    
    echo
    echo "|Default Gateway|"
    echo "────────────────────────────────────────"
    ip route | grep default | awk '{printf "Gateway: %s via %s\n", $3, $5}'
    
    echo
    echo "|DNS Servers|"
    echo "────────────────────────────────────────"
    if [ -f /etc/resolv.conf ]; then
        grep "nameserver" /etc/resolv.conf | awk '{printf "DNS: %s\n", $2}'
    else
        echo "DNS configuration not found"
    fi
    
    echo
    printf "\033[32m✓ Network information retrieved!\033[0m\n"
    echo
    read -p "Press Enter to continue..."
}

if [ "$EUID" -ne 0 ]; then
    echo "Warning: Some features require root privileges."
    echo "Run with sudo for full functionality."
    echo
fi

while true; do
    clear
    show_menu
    read choice
    
    case $choice in
        1)
            user_management
            ;;
        2)
            system_health
            ;;
        3)
            backup_tool
            ;;
        4)
            log_scanner
            ;;
        5)
            network_info
            ;;
        6)
            echo "Good bye!"
            exit 0
            ;;
        *)
            echo "Invalid option! Please choose 1-6."
            sleep 2
            ;;
    esac
done