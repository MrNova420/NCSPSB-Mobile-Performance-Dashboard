#!/data/data/com.termux/files/usr/bin/bash

# =========================================================
# NCSPSB-Mobile Performance Dashboard (Ultimate Combined Edition)
# Author: MrNova420
# Github: https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard
# =========================================================

# --------[ Colors & UI ]--------
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
MAGENTA="\033[35m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${CYAN}[i] Starting enhanced environment checks...${RESET}"

# --------[ Environment Detection ]--------
if [ -n "$PREFIX" ] && [[ "$PREFIX" == *"com.termux"* ]]; then
  ENVIRONMENT="Termux"
elif [ -f "/etc/andronix-release" ]; then
  ENVIRONMENT="Andronix"
elif [ -f "/etc/userland-release" ]; then
  ENVIRONMENT="UserLAnd"
else
  ENVIRONMENT="Unknown/Other"
fi
echo "[i] Detected environment: $ENVIRONMENT"

# --------[ Root tools usage prompt and opt-in ]--------
echo -e "${YELLOW}[!] Warning: This script may use root-related tools like 'proot' and 'tsu'${RESET}"
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

# --------[ Termux API check & install prompt ]--------
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

# --------[ UI Tools detection ]--------
if command -v dialog >/dev/null 2>&1; then
  UI_MODE="dialog"
elif command -v whiptail >/dev/null 2>&1; then
  UI_MODE="whiptail"
elif command -v fzf >/dev/null 2>&1; then
  UI_MODE="fzf"
else
  UI_MODE="basic"
fi
echo "[i] Selected UI mode: $UI_MODE"
if [[ "$UI_MODE" == "basic" ]]; then
  echo -e "${YELLOW}[!] No advanced UI tools detected. Using basic CLI menus.${RESET}"
fi

# --------[ Safe command execution wrapper ]--------
safe_exec() {
  "$@" >/dev/null 2>&1
  local STATUS=$?
  if [[ $STATUS -ne 0 ]]; then
    echo -e "${YELLOW}[Warning] Command failed: $*${RESET}"
  fi
  return $STATUS
}

confirm_action() {
  read -p "${YELLOW}Are you sure you want to proceed? [y/N]: ${RESET}" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

pause() { read -n 1 -s -r -p "Press any key to continue..."; echo; }
clear_screen() { clear || echo -e "\n"; }

# --------[ Storage permission setup ]--------
if ! [ -d "$HOME/storage" ]; then
  echo "[*] Requesting storage permissions..."
  termux-setup-storage
  sleep 2
fi

# --------[ Ensure running bash ]--------
if [ -z "$BASH_VERSION" ]; then
  echo "Please run this script using bash: bash script.sh"
  exit 1
fi

# --------[ Package installation & dependencies ]--------
REQUIRED_PKGS=(git curl wget proot tsu termux-tools termux-api vim nano zsh tmux python nodejs net-tools openssh lsof htop neofetch unzip tar grep sed awk jq clang make coreutils)
install_pkgs() {
  echo -e "${CYAN}[*] Checking & installing required base packages...${RESET}"
  safe_exec pkg update -y
  safe_exec pkg upgrade -y
  for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      echo -e "${YELLOW}Installing: $pkg${RESET}"
      safe_exec pkg install -y "$pkg"
    fi
  done
  echo -e "${GREEN}[✓] Required packages installed or already present.${RESET}"
}

# --------[ Human-readable bytes helper ]--------
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

# --------[ Auto-select fastest mirror ]--------
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
  pause
}

# --------[ Cache clearing ]--------
clear_cache() {
  echo -e "${CYAN}Clearing Termux package cache...${RESET}"
  rm -rf "$PREFIX/var/cache/apt/"* "$PREFIX/var/lib/apt/lists/"*
  echo -e "${GREEN}Cache cleared.${RESET}"
  pause
}

# --------[ Compiler optimizations ]--------
apply_compiler_optimizations() {
  echo -e "${CYAN}Applying compiler optimization flags...${RESET}"
  export CFLAGS="-O3 -march=native -pipe"
  export CXXFLAGS="$CFLAGS"
  echo -e "${GREEN}Compiler flags applied: CFLAGS=${CFLAGS}${RESET}"
  pause
}

# --------[ Full performance boost ]--------
full_performance_boost() {
  echo -e "${CYAN}Performing full performance boost...${RESET}"
  pkg autoclean -y
  pkg clean -y
  clear_cache
  apply_compiler_optimizations
  echo -e "${GREEN}Performance boost complete.${RESET}"
  pause
}

# --------[ Complete system info ]--------
complete_system_info() {
  clear_screen
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

  pause
}

# --------[ Network interface detection ]--------
get_network_interfaces() {
  WIFI_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^wlan0|^wlan' | head -n1)
  DATA_IFACE=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^rmnet|^usb' | head -n1)
}

# --------[ Calculate network speed ]--------
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

# --------[ Live status panel ]--------
live_status_panel() {
  clear_screen
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

    clear_screen
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

# --------[ Network info panel ]--------
network_panel() {
  echo -e "${CYAN}${BOLD}===== Network Info =====${RESET}"
  local_ip=$(ip addr show | awk '/inet / {print $2}' | awk 'NR==1{print $1}')
  public_ip=$(curl -s ifconfig.me || curl -s icanhazip.com)
  ssid=$(termux-wifi-connectioninfo 2>/dev/null | jq -r '.ssid' || echo "N/A")
  signal=$(termux-wifi-scaninfo 2>/dev/null | jq -r '.[0].level' || echo "N/A")
  conn_type=$(ip route | grep default | awk '{print $5}' || echo "N/A")
  mac_addr=$(ip link | grep link/ether | awk '{print $2}' | head -n1)
  gateway=$(ip route | grep default | awk '{print $3}' || echo "N/A")
  dns=$(getprop net.dns1 || echo "N/A")
  speed_test=$(curl -s https://speedtest.net | grep -o '[0-9]* Mbps' | head -n1 || echo "N/A")
  echo -e "Local IP: ${BOLD}$local_ip${RESET}"
  echo -e "Public IP: ${BOLD}$public_ip${RESET}"
  echo -e "WiFi SSID: ${BOLD}$ssid${RESET} | Signal: ${BOLD}$signal${RESET}"
  echo -e "Connection Type: ${BOLD}$conn_type${RESET}"
  echo -e "MAC Address: ${BOLD}$mac_addr${RESET}"
  echo -e "Gateway: ${BOLD}$gateway${RESET} | DNS: ${BOLD}$dns${RESET}"
  echo -e "Speed (est.): ${BOLD}$speed_test${RESET}"
  echo -e "Active Interfaces: $(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2}')"
  echo -e "--------------------------------------"
}

# --------[ Device info panel ]--------
device_panel() {
  echo -e "${CYAN}${BOLD}===== Device Info =====${RESET}"
  model=$(getprop ro.product.model)
  manufacturer=$(getprop ro.product.manufacturer)
  android_ver=$(getprop ro.build.version.release)
  cpu_model=$(grep 'model name' /proc/cpuinfo | uniq | cut -d: -f2)
  cpu_cores=$(grep -c ^processor /proc/cpuinfo)
  cpu_temp=$(termux-sensor -s temperature 2>/dev/null | jq -r '.[0].value' || echo "N/A")
  ram_total=$(free -h | awk '/Mem:/ {print $2}')
  ram_used=$(free -h | awk '/Mem:/ {print $3}')
  disk_total=$(df -h / | awk 'NR==2{print $2}')
  disk_free=$(df -h / | awk 'NR==2{print $4}')
  battery=$(termux-battery-status 2>/dev/null | jq '.percentage' || echo "N/A")
  battery_temp=$(termux-battery-status 2>/dev/null | jq '.temperature' || echo "N/A")
  uptime=$(uptime -p)
  boot=$(who -b | awk '{print $3,$4}')
  root_status=$($USE_ROOT && echo "Yes" || echo "No")
  echo -e "Model: ${BOLD}$model${RESET} | Manufacturer: ${BOLD}$manufacturer${RESET}"
  echo -e "Android Version: ${BOLD}$android_ver${RESET}"
  echo -e "CPU: ${BOLD}$cpu_model${RESET} | Cores: ${BOLD}$cpu_cores${RESET} | Temp: ${BOLD}$cpu_temp°C${RESET}"
  echo -e "RAM: ${BOLD}$ram_used/$ram_total${RESET}"
  echo -e "Disk: ${BOLD}$disk_free/$disk_total${RESET}"
  echo -e "Battery: ${BOLD}$battery%${RESET} | Temp: ${BOLD}$battery_temp°C${RESET}"
  echo -e "Uptime: ${BOLD}$uptime${RESET} | Boot: ${BOLD}$boot${RESET}"
  echo -e "Root: ${BOLD}$root_status${RESET}"
  echo -e "--------------------------------------"
}

# --------[ Environment info panel ]--------
environment_panel() {
  echo -e "${CYAN}${BOLD}===== Termux/Env Info =====${RESET}"
  termux_ver=$(termux-info | grep Version | head -n1 | awk '{print $2}')
  shell=$(echo $SHELL)
  user=$(whoami)
  pkg_count=$(pkg list-installed | wc -l)
  api_status=$(command -v termux-battery-status >/dev/null 2>&1 && echo "Yes" || echo "No")
  python_ver=$(python --version 2>&1 | awk '{print $2}' || echo "N/A")
  node_ver=$(node --version 2>&1 || echo "N/A")
  tmux_sessions=$(tmux list-sessions 2>/dev/null | wc -l)
  home_usage=$(du -sh ~ | awk '{print $1}')
  echo -e "Termux Version: ${BOLD}$termux_ver${RESET}"
  echo -e "Shell: ${BOLD}$shell${RESET} | User: ${BOLD}$user${RESET}"
  echo -e "Installed Packages: ${BOLD}$pkg_count${RESET}"
  echo -e "Termux API: ${BOLD}$api_status${RESET}"
  echo -e "Python: ${BOLD}$python_ver${RESET} | NodeJS: ${BOLD}$node_ver${RESET}"
  echo -e "Tmux Sessions: ${BOLD}$tmux_sessions${RESET}"
  echo -e "Home Usage: ${BOLD}$home_usage${RESET}"
  echo -e "--------------------------------------"
}

# --------[ Sensors panel ]--------
sensors_panel() {
  echo -e "${CYAN}${BOLD}===== Sensors =====${RESET}"
  sensors=$(termux-sensor -l 2>/dev/null | jq -r '.[].name' || echo "N/A")
  echo -e "Available Sensors:"
  echo -e "${BOLD}$sensors${RESET}"
  light=$(termux-sensor -s light 2>/dev/null | jq -r '.[0].value' || echo "N/A")
  accel=$(termux-sensor -s accelerometer 2>/dev/null | jq -r '.[0].value' || echo "N/A")
  gyro=$(termux-sensor -s gyroscope 2>/dev/null | jq -r '.[0].value' || echo "N/A")
  echo -e "Light: ${BOLD}$light${RESET} | Accelerometer: ${BOLD}$accel${RESET} | Gyro: ${BOLD}$gyro${RESET}"
  echo -e "--------------------------------------"
}

# --------[ Alerts system ]--------
ALERTS=()
add_alert() {
  ALERTS+=("$1")
}
show_alerts() {
  if [ ${#ALERTS[@]} -eq 0 ]; then
    echo -e "${GREEN}[✓] No active alerts.${RESET}"
  else
    echo -e "${RED}===== Alerts & Warnings =====${RESET}"
    for alert in "${ALERTS[@]}"; do
      echo -e "${RED}[!] $alert${RESET}"
    done
    echo -e "${RED}=============================${RESET}"
  fi
}
reset_alerts() { ALERTS=(); }

# --------[ Live health overview panel ]--------
live_health_panel() {
  clear_screen
  reset_alerts
  echo -e "${MAGENTA}${BOLD}===== Live Device Health Overview =====${RESET}"
  device_panel
  network_panel
  environment_panel
  sensors_panel

  # Check health thresholds
  ram_used_pct=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
  disk_used_pct=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
  battery_temp=$(termux-battery-status 2>/dev/null | jq '.temperature' || echo "0")
  battery_pct=$(termux-battery-status 2>/dev/null | jq '.percentage' || echo "0")
  cpu_temp=$(termux-sensor -s temperature 2>/dev/null | jq -r '.[0].value' || echo "0")

  # Alerts
  [ "$ram_used_pct" -gt 90 ] && add_alert "RAM usage high: $ram_used_pct%"
  [ "$disk_used_pct" -gt 90 ] && add_alert "Disk usage high: $disk_used_pct%"
  [ "$battery_temp" != "null" ] && [ "$battery_temp" -gt 42 ] && add_alert "Battery temp high: $battery_temp°C"
  [ "$cpu_temp" != "null" ] && [ "$cpu_temp" -gt 70 ] && add_alert "CPU temp high: $cpu_temp°C"
  [ "$battery_pct" != "null" ] && [ "$battery_pct" -lt 15 ] && add_alert "Battery low: $battery_pct%"

  show_alerts
  pause
}

# --------[ Performance boost panel ]--------
performance_boost() {
  echo -e "${YELLOW}Safe performance tweaks will be applied.${RESET}"
  if ! confirm_action; then
    echo -e "${RED}Cancelled by user.${RESET}"
    pause; return
  fi
  if $USE_ROOT; then
    safe_exec sysctl -w vm.swappiness=10
    safe_exec sysctl -w fs.inotify.max_user_watches=524288
    echo -e "${GREEN}Root tweaks applied.${RESET}"
  else
    echo -e "${YELLOW}Root not detected or disabled. Skipping root-only tweaks.${RESET}"
  fi

  # Termux tweaks
  if [ -f ~/.termux/termux.properties ]; then
    grep -q 'extra-keys' ~/.termux/termux.properties || echo 'extra-keys = [["ESC","TAB","CTRL","ALT","UP","DOWN","LEFT","RIGHT"]]' >> ~/.termux/termux.properties
    termux-reload-settings
    echo -e "${GREEN}Termux tweaks applied.${RESET}"
  fi
  echo -e "${GREEN}[✓] Performance boost complete!${RESET}"
  pause
}

# --------[ Update manager ]--------
update_manager() {
  echo -e "${CYAN}Checking for updates...${RESET}"
  if [ -d ".git" ]; then
    safe_exec git pull origin main
    echo -e "${GREEN}[✓] Update check complete.${RESET}"
  else
    echo -e "${YELLOW}No git repository found. Skipping update.${RESET}"
  fi
  pause
}

# --------[ Settings & customization panel ]--------
settings_panel() {
  echo -e "${MAGENTA}${BOLD}===== Settings & Customization =====${RESET}"
  echo "1) Change dashboard theme (colors)"
  echo "2) Set auto-refresh interval"
  echo "3) Enable/disable panels"
  echo "4) Restore default settings"
  echo "5) Back"
  read -p "Choose option: " opt
  case "$opt" in
    1) echo "Theme change not yet implemented."; pause ;;
    2) echo "Auto-refresh not yet implemented."; pause ;;
    3) echo "Panel toggling not yet implemented."; pause ;;
    4) echo "Defaults restored."; pause ;;
    5) return ;;
    *) echo "Invalid option."; sleep 1 ;;
  esac
}

# --------[ Help/About panel ]--------
help_panel() {
  clear_screen
  echo -e "${MAGENTA}${BOLD}===== Help & About =====${RESET}"
  echo "NCSPSB-Mobile Dashboard Ultimate Edition"
  echo "Author: MrNova420"
  echo "Features: Device health, network, system info, sensors, alerts, performance boost, update manager."
  echo "Run in Termux on any Android device. Root optional for advanced tweaks."
  echo "Need help? Visit: https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard"
  pause
}

# --------[ Main menu ]--------
main_menu() {
  while true; do
    clear_screen
    echo -e "${MAGENTA}${BOLD}========== NCSPSB-Mobile Dashboard ==========${RESET}"
    echo -e "${CYAN}1) Live Health Overview"
    echo "2) Network Info Panel"
    echo "3) Device Info Panel"
    echo "4) Termux/Environment Info Panel"
    echo "5) Sensors Panel"
    echo "6) Alerts & Notifications"
    echo "7) Performance Boost"
    echo "8) Update Manager"
    echo "9) Settings & Customization"
    echo "10) Help/About"
    echo "0) Exit${RESET}"
    echo -e "${MAGENTA}=============================================${RESET}"
    show_alerts
    read -p "Choose option [0-10]: " opt
    case "$opt" in
      1) live_health_panel ;;
      2) network_panel; pause ;;
      3) device_panel; pause ;;
      4) environment_panel; pause ;;
      5) sensors_panel; pause ;;
      6) show_alerts; pause ;;
      7) performance_boost ;;
      8) update_manager ;;
      9) settings_panel ;;
      10) help_panel ;;
      0) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
      *) echo -e "${RED}Invalid option. Please try again.${RESET}"; sleep 1 ;;
    esac
  done
}

# --------[ Entry point ]--------
main() {
  clear_screen
  echo -e "${GREEN}[✓] Starting NCSPSB-Mobile Dashboard...${RESET}"
  install_pkgs
  if command -v termux-battery-status >/dev/null 2>&1; then
    echo -e "${GREEN}[✓] Termux API detected and enabled.${RESET}"
  else
    add_alert "Termux:API not installed or not functioning. Some features may be limited."
  fi
  main_menu
}

main
