# System Admin Tools 

A Bash-based menu-driven toolkit for common Linux system administration tasks.

---

## Features

### 1. User Management
- Add, remove, and list users
- Set passwords
- Assign groups
- View detailed user information

### 2. System Health Check
- CPU, RAM, and disk usage
- Top processes by CPU & memory
- System uptime

### 3. Backup Tool
- Create compressed `.tar.gz` backups of directories
- Saves backups to `/backups`

### 4. Log Scanner
- Scans `/var/log/auth.log` for failed login attempts
- Generates a detailed report in `/tmp/failed_logins_TIMESTAMP.txt`
- Highlights suspicious activity

### 5. Network Info
- Interfaces & IPs
- Listening ports
- Active connections
- Network statistics
- Default gateway & DNS servers

---

## Installation

Clone or copy the script to your system and make it executable:

```bash
git clone https://github.com/your-repo/sysadmin-tools.git
cd sysadmin-tools
chmod +x sysadmin_tools.sh
```

## Usage

Run the script:

```bash
./sysadmin_tools.sh
```

> **Note:** Some features (user management, backup, log scanning) require root privileges.
> Run with `sudo` for full functionality.

## File Locations

### Backup Location
Backups are stored in:
```
/backups/
```

### Reports
Reports are saved in:
```
/tmp/failed_logins_TIMESTAMP.txt
```

## Requirements

- Linux system with bash
- Required utilities:
  - `awk`
  - `sed`
  - `ps`
  - `df`
  - `free`
  - `tar`
  - `netstat`
  - `ip`
  - `less`

