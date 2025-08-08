#!/data/data/com.termux/files/usr/bin/bash
# ========================================================
# Pre-Setup for NCSPSB-Mobile: Auto Install + Permissions
# ========================================================

echo "[*] Initializing environment setup..."

# Request storage permission (only once)
if ! [ -d "$HOME/storage" ]; then
  echo "[*] Requesting storage permissions..."
  termux-setup-storage
  sleep 2
fi

# Ensure bash is the shell (in case script launched in sh)
if [ -z "$BASH_VERSION" ]; then
  echo "Please run this script using bash: bash script.sh"
  exit 1
fi

# Auto install core Termux + system utilities if missing
echo "[*] Checking & installing required base packages..."
pkg update -y && pkg upgrade -y
pkg install -y git curl wget proot tsu termux-tools termux-api

# Optional: Extra utilities that may be required by system
EXTRAS=(vim nano zsh tmux python nodejs net-tools openssh lsof htop neofetch unzip tar grep sed awk jq clang make coreutils)

for pkg in "${EXTRAS[@]}"; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    echo "Installing missing package: $pkg"
    pkg install -y "$pkg"
  fi
done

echo "[✓] Pre-setup complete. Launching main NCSPSB-Mobile script..."
sleep 1

# ====================================
# Begin Original NCSPSB-Mobile Script
# (everything from your provided code)
# ====================================

# INSERT YOUR ORIGINAL SCRIPT BELOW THIS LINE (unchanged)
# You already shared the whole source so just keep it as is.


#!/bin/bash

# ======================
# NCSPSB-Mobile Performance Dashboard
# Fully featured with:
# - Auto update/upgrade + repos + dependencies
# - Mirror auto-selection
# - Cache clearing
# - Compiler optimizations
# - Full performance boost
# - System info
# - Live status panel (CPU, RAM, Disk, Network, Battery, Temp)
# - Safe error handling and user-friendly output
# - Auto-install and shortcut setup
# ======================

# Color codes
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
BOLD="\033[1m"
RESET="\033[0m"

# Check if running from $PREFIX/bin/boost
EXPECTED_PATH="$PREFIX/bin/boost"

setup() {
  echo -e "${CYAN}Starting auto-install and setup...${RESET}"

  # Install dependencies
  install_dependencies

  # Copy script to $PREFIX/bin/boost for shortcut command
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

# Helper: human-readable bytes
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

install_dependencies() {
  echo -e "${CYAN}Installing dependencies...${RESET}"

  pkg update -y && pkg upgrade -y

  local pkgs=(coreutils procps util-linux termux-api jq iproute2 curl wget nano vim zsh tmux htop ncdu python python-pip nodejs clang make openssh net-tools inetutils dnsutils termux-tools proot tsu)

  for p in "${pkgs[@]}"; do
    if ! command -v "$p" &>/dev/null && ! dpkg -s "$p" &>/dev/null; then
      echo -e "Installing ${YELLOW}$p${RESET}..."
      pkg install -y "$p" || echo -e "${RED}Failed to install $p.${RESET}"
    fi
  done

  echo -e "${GREEN}Dependencies installed or already present.${RESET}"
}

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

clear_cache() {
  echo -e "${CYAN}Clearing Termux package cache...${RESET}"
  rm -rf "$PREFIX/var/cache/apt/"* "$PREFIX/var/lib/apt/lists/"*
  echo -e "${GREEN}Cache cleared.${RESET}"
  read -p "Press Enter to continue..."
}

apply_compiler_optimizations() {
  echo -e "${CYAN}Applying compiler optimization flags...${RESET}"
  export CFLAGS="-O3 -march=native -pipe"
  export CXXFLAGS="$CFLAGS"
  echo -e "${GREEN}Compiler flags applied: CFLAGS=${CFLAGS}${RESET}"
  read -p "Press Enter to continue..."
}

full_performance_boost() {
  echo -e "${CYAN}Performing full performance boost...${RESET}"
  pkg autoclean -y
  pkg clean -y
  clear_cache
  apply_compiler_optimizations
  echo -e "${GREEN}Performance boost complete.${RESET}"
  read -p "Press Enter to continue..."
}

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

get_network_interfaces() {
  WIFI_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^wlan0|^wlan' | head -n1)
  DATA_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^rmnet|^usb' | head -n1)
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

live_status_panel() {
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

main_menu() {
  while true; do
    clear

    CPU_LOAD=$(top -bn1 | grep "CPU" | awk '{print $2 " " $3}' || echo "N/A")
    RAM_USE=$(free -h | awk '/Mem:/ {print $3 "/" $2}' || echo "N/A")
    DISK_USE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "N/A")
    BATTERY_PERC=$(termux-battery-status 2>/dev/null | jq '.percentage' 2>/dev/null || echo "N/A")

    echo -e "${BOLD}${CYAN}====== NCSPSB-Mobile Performance Dashboard ======${RESET}"
    echo -e "${GREEN}Hostname:${RESET} $(hostname)"
    echo -e "${GREEN}Uptime:${RESET} $(uptime -p)"
    echo -e "${GREEN}CPU Load:${RESET} $CPU_LOAD | RAM Usage: $RAM_USE | Disk Use: $DISK_USE | Battery: $BATTERY_PERC%"
    echo "=================================================="
    echo "[1] Update, Upgrade & Add All Repos"
    echo "[2] Auto-Select Fastest Secure Mirror"
    echo "[3] Clear Cache"
    echo "[4] Apply Compiler Optimizations"
    echo "[5] Run Full Performance Boost"
    echo "[6] Complete System Info"
    echo "[7] Live Status Panel (CPU, RAM, Net, Battery)"
    echo "[0] Exit"
    echo "=================================================="
    read -p "Choose option: " opt

    case $opt in
      1)
        install_dependencies
        ;;
      2)
        auto_select_fastest_mirror
        ;;
      3)
        clear_cache
        ;;
      4)
        apply_compiler_optimizations
        ;;
      5)
        full_performance_boost
        ;;
