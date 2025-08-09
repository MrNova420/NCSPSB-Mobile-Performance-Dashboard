# NCSPSB-Mobile Performance Dashboard (Ultimate Combined Edition)

---

## Overview

**NCSPSB-Mobile** is a fully-featured, all-in-one performance monitoring and utility dashboard designed for Android devices running **Termux**. It provides detailed system info, live device health stats, network info, sensor data, alerts, performance optimizations, and update management—all accessible from a clean terminal-based menu.

This unified script merges multiple versions and feature sets into a single stable, optimized, and user-friendly tool designed to give you full control and insight over your Android system’s performance and environment.

---

## Features

- **Environment Detection:** Auto-detects Termux, Andronix, UserLAnd, or other Linux-like environments on Android.
- **Root Usage Optional:** Safely enables root-dependent features like kernel tweaks if you choose.
- **Live Health Overview:** Displays CPU, RAM, Disk usage, battery stats, temperature warnings, and alerts.
- **Network Info Panel:** Shows local and public IPs, Wi-Fi details, MAC, DNS, gateway, and approximate speed.
- **Device Info Panel:** Hardware model, Android version, CPU specs, RAM, disk, battery status, uptime, and root state.
- **Environment Info:** Termux version, shell, installed packages, API status, Python & NodeJS versions, tmux sessions.
- **Sensors Panel:** Lists available sensors with current readings (light, accelerometer, gyroscope).
- **Alerts & Notifications:** Live alerts for high RAM/disk usage, battery or CPU temperature, low battery, etc.
- **Performance Boost:** Applies safe compiler flags and system tweaks to optimize performance.
- **Update Manager:** Pulls latest updates if installed from a git repo.
- **Settings & Customization:** Basic placeholders for theme, auto-refresh, panel toggles.
- **Help & About:** Information about the project, author, and usage links.

---

## Prerequisites

- Android device with Termux installed from F-Droid or official source.
- Basic familiarity with terminal commands.
- Optional root access for advanced tweaks (if enabled).
- Termux API app installed for battery and sensor features (`termux-api` package).

---

## Installation & Setup

### 1. Install Termux and Termux API

Install Termux from [F-Droid](https://f-droid.org/en/packages/com.termux/) (recommended).

Open Termux and run:

```bash
pkg update && pkg upgrade -y
pkg install termux-api git curl jq dialog whiptail fzf -y
Install Termux:API app from F-Droid to enable sensor and battery features.

2. Download the NCSPSB-Mobile Script
bash
Copy
Edit
cd ~
git clone https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard.git
cd NCSPSB-Mobile-Performance-Dashboard
chmod +x ncspsb-mobile.sh
Alternatively, copy the entire script into a file named ncspsb-mobile.sh.

3. Run the Dashboard
bash
Copy
Edit
./ncspsb-mobile.sh
Usage Guide
After launching, you will be prompted for root feature enablement.

The main menu displays options from live health overview to performance tweaks.

Navigate menus by entering numbers and following on-screen instructions.

Use q in live panels to exit back to the menu.

Alerts will display any critical warnings about your system.

Performance boost applies safe tweaks, optionally with root.

Update manager syncs the script with the latest git repo changes.

Settings panel has basic placeholders for future customization.

Quick Start Copy-Paste Commands
bash
Copy
Edit
# Update packages and install dependencies
pkg update && pkg upgrade -y
pkg install termux-api git curl jq dialog whiptail fzf -y

# Download script from GitHub (or use your saved script)
git clone https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard.git
cd NCSPSB-Mobile-Performance-Dashboard

# Make script executable
chmod +x ncspsb-mobile.sh

# Run the dashboard
./ncspsb-mobile.sh
Tips
For root features, allow root access when prompted; otherwise, features requiring root will be skipped safely.

To enable storage access, grant Termux storage permissions by running:

bash
Copy
Edit
termux-setup-storage
Keep your Termux environment updated to ensure compatibility.

The script auto-detects the best UI tools installed (dialog, whiptail, fzf) for enhanced menus.

Use Ctrl+C to abort any running process or command.

Explore all panels to get full system insight and optimize performance.

Troubleshooting
Termux API errors: Ensure the Termux:API app is installed and the termux-api package is present.

Missing dependencies: Run the install commands above again.

Root not working: Confirm your device is rooted and you have granted Termux root permissions.

Network info not showing: Verify you have active internet connections or Wi-Fi.

Contribution & Support
This project is open source and available on GitHub:

https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard

Feel free to fork, report issues, or contribute improvements.

License
This project is licensed under the MIT License — see the LICENSE file for details.
