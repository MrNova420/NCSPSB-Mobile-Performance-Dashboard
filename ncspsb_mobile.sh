#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# NCSPSB-Mobile-Performance-Dashboard v2.0
# Nova Control System Performance Status Board (Mobile Edition)
# Author: MrNova420 | License: MIT | Status: Public Release
# All-in-one performance dashboard and utility suite for Termux/Linux Android
# ======================================================

### METADATA & PROJECT INFO
PROJECT_NAME="NCSPSB-Mobile"
PROJECT_VERSION="2.0"
LOG_DIR="$HOME/.ncspsb-logs"
LOG_FILE="$LOG_DIR/ncspsb.log"
EXPORT_DIR="$HOME/.ncspsb-exports"
REFRESH=3
THEME="default" # Placeholder for future theme packs
MENU_MODE="classic"
WATCHDOG_ENABLED=true
REQUIRED_PKGS=(dialog termux-api coreutils grep awk sed bc fzf curl jq)
declare -A PANEL_FUNCS

### COLOR THEMES (Easy to expand in future)
RED='\e[31m'
GRN='\e[32m'
YEL='\e[33m'
BLU='\e[34m'
RST='\e[0m'

### LOGGING SYSTEM (Safer, more robust)
log() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

### NOTIFICATION SYSTEM (Clearer warnings)
notify() {
    if command -v termux-notification &>/dev/null; then
        termux-notification --title "$PROJECT_NAME" --content "$*" --priority high
    else
        echo -e "${YEL}[NOTIFY]${RST} $*"
    fi
}

warn() {
    echo -e "${RED}[WARNING]${RST} $*"
    notify "WARNING: $*"
}

### ENVIRONMENT & DEPENDENCIES
check_permissions() {
    termux-setup-storage &>/dev/null || warn "Termux storage permission not granted."
}

check_env() {
    log "Detecting environment..."
    if [[ $(whoami) == "root" ]]; then
        ENVIRONMENT="Rooted"
    elif [[ -d /data/data/com.termux ]]; then
        ENVIRONMENT="Termux"
    elif grep -q "ubuntu" /etc/os-release 2>/dev/null; then
        ENVIRONMENT="Ubuntu"
    else
        ENVIRONMENT="Unknown"
    fi
    log "Environment: $ENVIRONMENT"
}

auto_install() {
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            log "Installing missing dependency: $pkg"
            pkg install -y "$pkg" 2>/dev/null || apt update && apt install -y "$pkg"
            if ! command -v "$pkg" &>/dev/null; then
                warn "Failed to install $pkg. Please install manually."
            fi
        fi
    done
}

### BACKGROUND WATCHDOG IMPLEMENTATION
WATCHDOG_PID_FILE="$LOG_DIR/watchdog.pid"

start_watchdog() {
    if [[ -f "$WATCHDOG_PID_FILE" ]] && kill -0 $(cat "$WATCHDOG_PID_FILE") 2>/dev/null; then
        warn "Watchdog already running (PID $(cat $WATCHDOG_PID_FILE))"
        return
    fi
    (
        while true; do
            # Battery
            if command -v jq &>/dev/null; then
                BAT=$(termux-battery-status | jq '.percentage' 2>/dev/null)
                [[ -z "$BAT" || "$BAT" == "null" ]] && BAT=-1
            else
                BAT=$(termux-battery-status | grep percentage | awk '{print $2}' | tr -d ',')
                [[ -z "$BAT" ]] && BAT=-1
            fi
            # CPU Temp
            CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
            CPU_TEMP_C=$((CPU_TEMP/1000))
            [[ -z "$CPU_TEMP_C" || "$CPU_TEMP_C" == "0" ]] && CPU_TEMP_C=0

            if [[ "$BAT" -ge 0 && "$BAT" -lt 15 ]]; then
                log "Watchdog: Low Battery $BAT%"
                notify "Watchdog: Low Battery $BAT%"
            fi
            if [[ "$CPU_TEMP_C" -gt 70 ]]; then
                log "Watchdog: High CPU Temp $CPU_TEMP_C°C"
                notify "Watchdog: High CPU Temp $CPU_TEMP_C°C"
            fi
            sleep 60 # Check every 60 seconds
        done
    ) &
    echo $! > "$WATCHDOG_PID_FILE"
    log "Started Watchdog (PID $!)"
    notify "Watchdog started (PID $!)"
}

stop_watchdog() {
    if [[ -f "$WATCHDOG_PID_FILE" ]] && kill -0 $(cat "$WATCHDOG_PID_FILE") 2>/dev/null; then
        kill $(cat "$WATCHDOG_PID_FILE")
        log "Stopped Watchdog (PID $(cat "$WATCHDOG_PID_FILE"))"
        notify "Watchdog stopped"
        rm -f "$WATCHDOG_PID_FILE"
    else
        warn "Watchdog not running"
    fi
}

show_watchdog_status() {
    if [[ -f "$WATCHDOG_PID_FILE" ]] && kill -0 $(cat "$WATCHDOG_PID_FILE") 2>/dev/null; then
        echo -e "${GRN}Watchdog running (PID $(cat $WATCHDOG_PID_FILE))${RST}"
    else
        echo -e "${RED}Watchdog not running${RST}"
    fi
}

### PANEL: SYSTEM INFO (Cleaner memory logic)
system_info() {
    echo -e "${BLU}-- SYSTEM INFO --${RST}"
    echo "Device: $(getprop ro.product.model 2>/dev/null)"
    echo "Android: $(getprop ro.build.version.release 2>/dev/null)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)"
    echo "Cores: $(grep -c ^processor /proc/cpuinfo)"
    mem_total=$(free -h | grep Mem | awk '{print $2}')
    mem_used=$(free -h | grep Mem | awk '{print $3}')
    echo "RAM: ${mem_used}/${mem_total}"
    # Battery
    if command -v jq &>/dev/null; then
        bat=$(termux-battery-status | jq '.percentage' 2>/dev/null)
        [[ -z "$bat" || "$bat" == "null" ]] && bat="N/A"
    else
        bat=$(termux-battery-status | grep percentage | awk '{print $2}' | tr -d ',')
        [[ -z "$bat" ]] && bat="N/A"
    fi
    echo "Battery: ${bat}%"
    echo "Disk: $(df -h $HOME | tail -1 | awk '{print $4}') free"
}
PANEL_FUNCS["System Info"]=system_info

### PANEL: NETWORK INFO (Better SSID fallback)
network_panel() {
    echo -e "${BLU}-- NETWORK INFO --${RST}"
    if command -v jq &>/dev/null; then
        ssid=$(termux-wifi-connectioninfo | jq -r '.ssid' 2>/dev/null)
        [[ -z "$ssid" || "$ssid" == "null" ]] && ssid="N/A"
    else
        ssid=$(termux-wifi-connectioninfo | grep ssid | awk '{print $2}')
        [[ -z "$ssid" ]] && ssid="N/A"
    fi
    echo "WiFi SSID: ${ssid}"
    ip=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    [[ -z "$ip" ]] && ip=$(ip addr show 2>/dev/null | grep 'inet ' | head -1 | awk '{print $2}')
    [[ -z "$ip" ]] && ip="N/A"
    echo "IP Address: ${ip}"
    ping_time=$(ping -c 1 google.com 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    [[ -z "$ping_time" ]] && ping_time="N/A"
    echo "Ping: ${ping_time} ms"
}
PANEL_FUNCS["Network"]=network_panel

### PANEL: PERFORMANCE BOOST (Logs & smarter root detection)
boost_panel() {
    echo -e "${GRN}-- PERFORMANCE BOOST --${RST}"
    echo "1. Clear RAM Cache (root only)"
    echo "2. Kill Background Processes (DANGEROUS!)"
    echo "3. Return"
    read -p "Select option: " opt
    case $opt in
        1)
            if [[ $ENVIRONMENT == "Rooted" ]]; then
                sync; echo 3 > /proc/sys/vm/drop_caches
                log "RAM Cache cleared"
            else
                warn "RAM Cache clear requires root!"
            fi
            ;;
        2)
            warn "This will kill all your user background processes and may close Termux itself."
            read -p "Type 'YES' to proceed: " confirm
            if [[ "$confirm" == "YES" ]]; then
                killall -u $(whoami)
                log "Background user processes killed"
            else
                echo "Operation cancelled."
            fi
            ;;
        *)
            return
            ;;
    esac
}
PANEL_FUNCS["Boost"]=boost_panel

### PANEL: ALERTS (Clearer outputs, fallback)
alerts_panel() {
    echo -e "${RED}-- ALERTS --${RST}"
    # Battery
    if command -v jq &>/dev/null; then
        BAT=$(termux-battery-status | jq '.percentage' 2>/dev/null)
        [[ -z "$BAT" || "$BAT" == "null" ]] && BAT=-1
    else
        BAT=$(termux-battery-status | grep percentage | awk '{print $2}' | tr -d ',')
        [[ -z "$BAT" ]] && BAT=-1
    fi
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    CPU_TEMP_C=$((CPU_TEMP/1000))
    [[ -z "$CPU_TEMP_C" || "$CPU_TEMP_C" == "0" ]] && CPU_TEMP_C=0
    [[ "$BAT" -ge 0 && "$BAT" -lt 15 ]] && warn "Low Battery: $BAT%"
    [[ "$CPU_TEMP_C" -gt 70 ]] && warn "High CPU Temp: $CPU_TEMP_C°C"
}
PANEL_FUNCS["Alerts"]=alerts_panel

### PANEL: SENSORS (Failure mode fallback)
sensors_panel() {
    echo -e "${BLU}-- SENSORS --${RST}"
    if termux-sensor -l &>/dev/null; then
        termux-sensor -l
        echo "Live Reading:"
        termux-sensor -n 1
    else
        warn "Sensors not available or permission not granted."
    fi
}
PANEL_FUNCS["Sensors"]=sensors_panel

### PANEL: EXPORT (Timestamp naming, logs)
export_panel() {
    mkdir -p "$EXPORT_DIR"
    TS=$(date '+%Y%m%d_%H%M%S')
    FILE="$EXPORT_DIR/system_report_$TS.txt"
    {
        system_info
        network_panel
        alerts_panel
    } > "$FILE"
    log "System exported to $FILE"
    echo "Report saved: $FILE"
}
PANEL_FUNCS["Export"]=export_panel

### PANEL: LOGS
logs_panel() {
    echo -e "${YEL}-- LOGS --${RST}"
    tail -n 20 "$LOG_FILE" 2>/dev/null || echo "No logs yet."
}
PANEL_FUNCS["Logs"]=logs_panel

### PANEL: SETTINGS (Now includes watchdog controls)
settings_panel() {
    echo -e "${YEL}-- SETTINGS --${RST}"
    show_watchdog_status
    echo "1. Refresh rate (Current: $REFRESH sec)"
    echo "2. Toggle Watchdog (Current: $WATCHDOG_ENABLED)"
    echo "3. Theme (Current: $THEME)"
    echo "4. Start Watchdog (background monitor)"
    echo "5. Stop Watchdog"
    echo "6. Back"
    read -p "Select option: " opt
    case $opt in
        1) read -p "Set refresh (sec): " r; REFRESH=${r:-3};;
        2) WATCHDOG_ENABLED=$( [[ $WATCHDOG_ENABLED == true ]] && echo false || echo true );;
        3) read -p "Set theme: " t; THEME=${t:-default};;
        4) start_watchdog;;
        5) stop_watchdog;;
        *) return;;
    esac
}
PANEL_FUNCS["Settings"]=settings_panel

### PANEL: LIVE STATUS (Stable)
live_status_panel() {
    while true; do
        clear
        system_info
        echo
        alerts_panel
        echo
        echo "(Updating every $REFRESH seconds, press Ctrl+C to exit)"
        sleep $REFRESH
    done
}
PANEL_FUNCS["Live Status"]=live_status_panel

### MAIN MENU SYSTEM (Cleaner handler)
show_menu() {
    local panels=("System Info" "Network" "Sensors" "Boost" "Alerts" "Logs" "Export" "Live Status" "Settings" "Exit")
    while true; do
        clear
        echo -e "${GRN}===== $PROJECT_NAME v${PROJECT_VERSION} =====${RST}"
        for i in "${!panels[@]}"; do
            echo "$((i+1)). ${panels[$i]}"
        done
        read -p "Choose option: " choice
        panel_name="${panels[$((choice-1))]}"
        [[ "$panel_name" == "Exit" ]] && break
        if [[ -n "${PANEL_FUNCS[$panel_name]}" ]]; then
            clear
            ${PANEL_FUNCS[$panel_name]}
            echo -e "\nPress Enter to return..."
            read
        fi
    done
}

### MAIN ENTRYPOINT (Packaging ready)
main() {
    check_env
    auto_install
    check_permissions
    show_menu
    log "Exited $PROJECT_NAME"
}

main
# End of Script
