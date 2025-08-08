#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# NCSPSB-Mobile-Performance-Dashboard v3.0 (Full Merge)
# Nova Control System Performance Status Board (Mobile Edition)
# Author: MrNova420 | License: MIT | Status: Public Release
# All-in-one performance dashboard and utility suite for Termux/Linux Android
# ======================================================

#############################
# --- COLORS AND THEMES --- #
#############################
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
MAGENTA="\033[35m"
BOLD="\033[1m"
RESET="\033[0m"
ULINE="\033[4m"

######################
# --- METADATA ---   #
######################
PROJECT_NAME="NCSPSB-Mobile"
PROJECT_VERSION="3.0"
LOG_DIR="$HOME/.ncspsb-logs"
LOG_FILE="$LOG_DIR/ncspsb.log"
EXPORT_DIR="$HOME/.ncspsb-exports"
REFRESH=3
THEME="default"
MENU_MODE="advanced"
WATCHDOG_ENABLED=true

##############################
# --- PACKAGES AND EXTRAS ---#
##############################
REQUIRED_PKGS=(dialog whiptail fzf termux-api coreutils grep awk sed bc curl jq nano null)
EXTRAS=(vim zsh tmux python nodejs net-tools openssh lsof htop neofetch unzip tar clang make procps util-linux iproute2 python-pip dnsutils inetutils ncdu)

declare -A PANEL_FUNCS

###########################
# --- ENV DETECTION ---   #
###########################
echo -e "${CYAN}[i] Starting enhanced environment checks...${RESET}"

if [ -n "$PREFIX" ] && [[ "$PREFIX" == *"com.termux"* ]]; then
  ENVIRONMENT="Termux"
elif [ -f "/etc/andronix-release" ]; then
  ENVIRONMENT="Andronix"
elif [ -f "/etc/userland-release" ]; then
  ENVIRONMENT="UserLAnd"
else
  ENVIRONMENT="Unknown/Other"
fi
echo -e "${MAGENTA}[i] Detected environment: $ENVIRONMENT${RESET}"

echo -e "${YELLOW}[!] This script may use root-related tools like 'proot' and 'tsu'${RESET}"
echo "Using these tools can affect system security and stability on some devices."
read -p "Enable root-dependent features? (Y/n): " ROOT_FEATURES_CHOICE
ROOT_FEATURES_CHOICE=${ROOT_FEATURES_CHOICE:-Y}
if [[ "$ROOT_FEATURES_CHOICE" =~ ^[Yy]$ ]]; then
  USE_ROOT=true
  echo -e "${GREEN}[i] Root-dependent features ENABLED.${RESET}"
else
  USE_ROOT=false
  echo -e "${YELLOW}[i] Root-dependent features DISABLED. Falling back to non-root modes where possible.${RESET}"
fi

if ! command -v termux-battery-status >/dev/null 2>&1; then
  echo -e "${YELLOW}[!] termux-api package or app missing or non-functional.${RESET}"
  read -p "Attempt to install termux-api package now? (Y/n): " INSTALL_TERMUX_API
  INSTALL_TERMUX_API=${INSTALL_TERMUX_API:-Y}
  if [[ "$INSTALL_TERMUX_API" =~ ^[Yy]$ ]]; then
    pkg install -y termux-api || echo -e "${RED}[!] Failed to install termux-api. Some features may not work.${RESET}"
  else
    echo "[i] Continuing without termux-api. Battery and advanced features may be limited."
  fi
fi

if command -v dialog >/dev/null 2>&1; then
  UI_MODE="dialog"
elif command -v whiptail >/dev/null 2>&1; then
  UI_MODE="whiptail"
elif command -v fzf >/dev/null 2>&1; then
  UI_MODE="fzf"
else
  UI_MODE="basic"
fi
echo -e "${MAGENTA}[i] Selected UI mode: $UI_MODE${RESET}"
if [[ "$UI_MODE" == "basic" ]]; then
  echo -e "${YELLOW}[!] No advanced UI tools (dialog/whiptail/fzf) detected. Using basic CLI menus.${RESET}"
fi

#############################
# --- SAFE EXEC WRAPPER --- #
#############################
safe_exec() {
  local CMD="$*"
  eval "$CMD"
  local STATUS=$?
  if [[ $STATUS -ne 0 ]]; then
    echo -e "${YELLOW}[Warning] Command failed: $CMD${RESET}"
  fi
  return $STATUS
}

#############################
# --- LOGGING/NOTIFY ---    #
#############################
log() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}
notify() {
    if command -v termux-notification &>/dev/null; then
        termux-notification --title "$PROJECT_NAME" --content "$*" --priority high
    else
        echo -e "${YELLOW}[NOTIFY]${RESET} $*"
    fi
}
warn() {
    echo -e "${RED}[WARNING]${RESET} $*"
    notify "WARNING: $*"
}
check_permissions() {
    termux-setup-storage &>/dev/null || warn "Termux storage permission not granted."
}

##############################
# --- AUTO INSTALL ---       #
##############################
auto_install() {
    echo -e "${CYAN}[*] Checking & installing required base packages...${RESET}"
    safe_exec pkg update -y && safe_exec pkg upgrade -y
    for pkg in "${REQUIRED_PKGS[@]}" "${EXTRAS[@]}"; do
      if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "Installing missing package: $pkg"
        safe_exec pkg install -y "$pkg"
      fi
    done
    echo -e "${GREEN}[✓] All packages present.${RESET}"
}

##############################
# --- SHORTCUT SETUP ---     #
##############################
EXPECTED_PATH="$PREFIX/bin/boost"
setup_shortcut() {
  echo -e "${CYAN}Starting auto-install and setup...${RESET}"
  auto_install
  if [[ ! -f "$EXPECTED_PATH" ]]; then
    echo -e "${CYAN}Installing shortcut command to $EXPECTED_PATH...${RESET}"
    mkdir -p "$(dirname "$EXPECTED_PATH")"
    cp "${BASH_SOURCE[0]}" "$EXPECTED_PATH"
    chmod +x "$EXPECTED_PATH"
    echo -e "${GREEN}Shortcut installed! You can now run this script by typing 'boost'${RESET}"
  else
    echo -e "${GREEN}Shortcut already installed at $EXPECTED_PATH${RESET}"
  fi
  echo -e "${CYAN}Setup complete!${RESET}"
  read -p "Press Enter to start the dashboard..."
  exec "$EXPECTED_PATH"
}

##############################
# --- MIRROR SELECTION ---   #
##############################
auto_select_fastest_mirror() {
  echo -e "${CYAN}Selecting fastest Termux mirror...${RESET}"
  local mirrors=(
    "https://packages-cf.termux.dev/apt/termux-main"
    "https://mirror.quantum5.ca/termux/termux-main"
    "https://grimler.se/termux-packages-24/"
  )
  local fastest_mirror=""
  local fastest_time=1000000
  for mirror in "${mirrors[@]}"; do
    local start=$(date +%s%N)
    curl -s --connect-timeout 3 --max-time 5 -o /dev/null "$mirror/InRelease"
    local end=$(date +%s%N)
    local diff=$(( (end - start)/1000000 ))
    echo "Mirror $mirror responded in ${diff} ms."
    if (( diff < fastest_time )); then
      fastest_time=$diff
      fastest_mirror=$mirror
    fi
  done
  echo -e "${GREEN}Fastest mirror is: $fastest_mirror (Response: ${fastest_time} ms)${RESET}"
  read -p "Press Enter to continue..."
}

##############################
# --- CACHE CLEAR ---        #
##############################
clear_cache() {
  echo -e "${CYAN}Clearing Termux package cache...${RESET}"
  rm -rf "$PREFIX/var/cache/apt/"* "$PREFIX/var/lib/apt/lists/"*
  echo -e "${GREEN}Cache cleared.${RESET}"
  read -p "Press Enter to continue..."
}

##############################
# --- COMPILER OPTIMIZE ---  #
##############################
apply_compiler_optimizations() {
  echo -e "${CYAN}Applying compiler optimization flags...${RESET}"
  export CFLAGS="-O3 -march=native -pipe"
  export CXXFLAGS="$CFLAGS"
  echo -e "${GREEN}Compiler flags applied: CFLAGS=${CFLAGS}${RESET}"
  read -p "Press Enter to continue..."
}

##############################
# --- PERF BOOST ---         #
##############################
full_performance_boost() {
  echo -e "${CYAN}Performing full performance boost...${RESET}"
  pkg autoclean -y
  pkg clean -y
  clear_cache
  apply_compiler_optimizations
  echo -e "${GREEN}Performance boost complete.${RESET}"
  read -p "Press Enter to continue..."
}

##############################
# --- SYSTEM INFO PANEL ---  #
##############################
complete_system_info() {
  clear
  echo -e "${BOLD}${CYAN}=== Complete System Info ===${RESET}"
  echo -e "${YELLOW}Kernel and OS Info:${RESET}"
  uname -a
  echo ""
  echo -e "${YELLOW}Disk Usage:${RESET}"
  df -h
  echo ""
  echo -e "${YELLOW}Memory Info:${RESET}"
  free -h
  echo ""
  echo -e "${YELLOW}CPU Info:${RESET}"
  lscpu 2>/dev/null || echo "lscpu not available"
  echo ""
  echo -e "${YELLOW}Installed Packages Count:${RESET}"
  dpkg-query -l | wc -l
  echo ""
  read -p "Press Enter to return to menu..."
}

##############################
# --- NETWORK INTERFACE ---  #
##############################
get_network_interfaces() {
  WIFI_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^wlan0|^wlan' | head -n1)
  DATA_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^rmnet|^usb' | head -n1)
}

##############################
# --- NETWORK SPEED ---      #
##############################
human_readable_bytes() {
  local b=${1:-0}
  local d=''
  local s=0
  local S=(Bytes KB MB GB TB PB)
  while ((b > 1024)); do
    d=$(printf ".%02d" $((b % 1024 * 100 / 1024)))
    b=$((b / 1024))
    ((s++))
  done
  echo "$b$d ${S[$s]}"
}
calc_net_speed() {
  local iface=$1
  if [[ -z "$iface" ]]; then
    RX_SPEED=0
    TX_SPEED=0
    return
  fi
  RX1=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
  TX1=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
  sleep 5
  RX2=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
  TX2=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
  RX_SPEED=$((RX2 - RX1))
  TX_SPEED=$((TX2 - TX1))
}

##############################
# --- LIVE STATUS PANEL ---  #
##############################
live_status_panel_full() {
  clear
  echo -e "${BOLD}${CYAN}====== NCSPSB-Mobile Live Status Panel ======${RESET}"
  echo -e "${YELLOW}Press 'q' then Enter anytime to quit panel.${RESET}"
  while true; do
    get_network_interfaces
    CPU_USAGE=$(top -bn1 | grep "CPU" | awk '{print $2 " " $3}' || echo "N/A")
    RAM_USED=$(free -h | awk '/Mem:/ {print $3}' || echo "N/A")
    RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}' || echo "N/A")
    DISK_USE=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}' || echo "N/A")
    calc_net_speed $WIFI_IFACE
    WIFI_RX_HR=$(human_readable_bytes $RX_SPEED)
    WIFI_TX_HR=$(human_readable_bytes $TX_SPEED)
    calc_net_speed $DATA_IFACE
    DATA_RX_HR=$(human_readable_bytes $RX_SPEED)
    DATA_TX_HR=$(human_readable_bytes $TX_SPEED)
    BATTERY_JSON=$(termux-battery-status 2>/dev/null)
    BATTERY_PERC=$(echo "$BATTERY_JSON" | jq '.percentage' 2>/dev/null || echo "N/A")
    BATTERY_TEMP=$(echo "$BATTERY_JSON" | jq '.temperature' 2>/dev/null || echo "N/A")
    clear
    echo -e "${BOLD}${CYAN}====== NCSPSB-Mobile Live Status Panel ======${RESET}"
    echo -e "${GREEN}Hostname:${RESET} $(hostname)"
    echo -e "${GREEN}Uptime:${RESET} $(uptime -p)"
    echo -e "${GREEN}CPU Usage:${RESET} $CPU_USAGE"
    echo -e "${GREEN}RAM Usage:${RESET} $RAM_USED / $RAM_TOTAL"
    echo -e "${GREEN}Disk Usage:${RESET} $DISK_USE"
    echo -e "${GREEN}Wi-Fi (${WIFI_IFACE:-N/A}):${RESET} Download $WIFI_RX_HR/s | Upload $WIFI_TX_HR/s"
    echo -e "${GREEN}Mobile Data (${DATA_IFACE:-N/A}):${RESET} Download $DATA_RX_HR/s | Upload $DATA_TX_HR/s"
    echo -e "${GREEN}Battery:${RESET} $BATTERY_PERC%    ${GREEN}Temperature:${RESET} $BATTERY_TEMP °C"
    echo -e "${YELLOW}Press 'q' then Enter to return to menu.${RESET}"
    read -t 5 -n 1 key
    if [[ "$key" == "q" ]]; then
      break
    fi
  done
}

##############################
# --- MAIN MENU ---          #
##############################
show_menu() {
    local panels=("System Info" "Network" "Sensors" "Boost" "Alerts" "Logs" "Export" "Live Status (Simple)" "Live Status Panel (Full)" "Complete System Info" "Auto-Select Mirror" "Clear Cache" "Compiler Optimizations" "Full Performance Boost" "Setup Shortcut" "Settings" "Exit")
    while true; do
        clear
        echo -e "${BOLD}${MAGENTA}=================================================="
        echo -e "${ULINE}${CYAN}${PROJECT_NAME} ${PROJECT_VERSION} | Performance Dashboard${RESET}"
        echo -e "${BOLD}${CYAN}Environment:${RESET} $ENVIRONMENT   ${BOLD}${CYAN}UI Mode:${RESET} $UI_MODE"
        echo -e "${BOLD}${CYAN}Root Features:${RESET} $USE_ROOT   ${BOLD}${CYAN}Theme:${RESET} $THEME"
        echo -e "${BOLD}${CYAN}Log File:${RESET} $LOG_FILE"
        echo -e "${MAGENTA}--------------------------------------------------${RESET}"
        for i in "${!panels[@]}"; do
            printf "${YELLOW}[%d]${RESET} %s\n" $((i+1)) "${panels[$i]}"
        done
        echo -e "${MAGENTA}==================================================${RESET}"
        read -p "Choose option: " choice
        panel_name="${panels[$((choice-1))]}"
        case "$panel_name" in
          "System Info") system_info;;
          "Network") network_panel;;
          "Sensors") sensors_panel;;
          "Boost") boost_panel;;
          "Alerts") alerts_panel;;
          "Logs") logs_panel;;
          "Export") export_panel;;
          "Live Status (Simple)") live_status_panel;;
          "Live Status Panel (Full)") live_status_panel_full;;
          "Complete System Info") complete_system_info;;
          "Auto-Select Mirror") auto_select_fastest_mirror;;
          "Clear Cache") clear_cache;;
          "Compiler Optimizations") apply_compiler_optimizations;;
          "Full Performance Boost") full_performance_boost;;
          "Setup Shortcut") setup_shortcut;;
          "Settings") settings_panel;;
          "Exit") log "User exited dashboard."; exit 0;;
          *) echo "Invalid option.";;
        esac
        echo -e "\n${CYAN}Press Enter to return to menu...${RESET}"
        read
    done
}

##############################
# --- MAIN ENTRYPOINT ---    #
##############################
main() {
    auto_install
    check_permissions
    show_menu
    log "Exited $PROJECT_NAME"
}

main

# End of Script
