# System Admin Tools v1.0

A Bash-based menu-driven toolkit for common Linux system administration tasks.  
Created by **AA**.

---

## Features

1. User Management
   - Add, remove, and list users
   - Set passwords
   - Assign groups
   - View detailed user information

2. System Health Check
   - CPU, RAM, and disk usage
   - Top processes by CPU & memory
   - System uptime

3. Backup Tool
   - Create compressed `.tar.gz` backups of directories
   - Saves backups to `/backups`

4. Log Scanner
   - Scans `/var/log/auth.log` for failed login attempts
   - Generates a detailed report (`/tmp/failed_logins_*.txt`)
   - Highlights suspicious activity

5. Network Info
   - Interfaces & IPs
   - Listening ports
   - Active connections
   - Network statistics
   - Default gateway & DNS servers

---

## Usage

1. Clone or copy the script:
   ```bash
   git clone https://github.com/your-repo/sysadmin-tools.git
   cd sysadmin-tools
   chmod +x sysadmin_tools.sh
Run the script:

bash
Copy
Edit
./sysadmin_tools.sh
Note: Some features (user management, backup, log scanning) require root privileges.
Run with sudo for full functionality.

Backup Location
Backups are stored in:

bash
Copy
Edit
/backups/
Reports are saved in:

bash
Copy
Edit
/tmp/failed_logins_TIMESTAMP.txt
Requirements
Linux system with bash

Utilities: awk, sed, ps, df, free, tar, netstat, ip, less

Disclaimer
This script is provided as-is without warranty.
Use with caution on production systems.
