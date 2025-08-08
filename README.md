# NCSPSB-Mobile-Performance-Dashboard

in beta - currently working on stable version relase Soon mostly stable already tho. 
will keep this a seperate repo but this is just a small feature for a bigger project that will later on be released and have tis merged as a side feature!

# 🚀 NCSPSB-Mobile Performance Dashboard

A powerful, interactive, and fully automated Termux-based performance dashboard for Android devices. **NCSPSB-Mobile** (Nova Custom System Performance Status Boost-Mobile) is your all-in-one solution to monitor, boost, and maintain the performance of your device directly from the terminal.

---

## 📦 Features

- 🔄 **Auto Update, Upgrade, and Setup**
- 🚀 **System Optimizations & Boost Tools**
- 🧰 **Auto-Install All Required Dependencies**
- 🧠 **Fast Mirror Auto-Selector**
- 🧹 **Cache Cleaning & Compiler Optimizations**
- 📊 **Live Status Panel (CPU, RAM, Disk, Network, Battery, Temp)**
- 🖥️ **Complete System Info Snapshot**
- ⚙️ **Safe Error Handling and User Feedback**
- 📁 **Auto-Termux Storage Access & Authorizations**
- 🏃‍♂️ **Shortcut Command Installer (`boost`)**
- 🔧 **Optional Homescreen Launcher Support (via Termux Widget)**

---

## 🔧 Auto-Setup

On first run, this script will:
1. Request storage permissions (if not yet granted)
2. Auto-install all essential & optional Termux packages
3. Set up a command-line shortcut (`boost`)
4. Launch the dashboard immediately

> **No manual configuration needed. Just run it and go.**

---

## 🛠 Requirements

- ✅ Android 7.0+
- ✅ [Termux](https://f-droid.org/en/packages/com.termux/) (from F-Droid only)
- ✅ Basic shell access (`bash`, `proot`, `tsu` if rooted)
- ✅ Internet access for installing packages

---

## 📥 Installation

### 🌀 Automatic One-Liner (Recommended)
Paste this in Termux:

```bash
pkg update -y && pkg install -y git curl && git clone https://github.com/MrNova420/NCSPSB-Mobile-Performance-Dashboard && cd NCSPSB-Mobile-Performance-Dashboard  && chmod +x ncspsb_mobile.sh && ./ncspsb_mobile.sh


🖥️ Usage
Once installed, simply run:

bash
Copy
Edit
boost
Or run the script manually:

bash
Copy
Edit
bash ncspsb.sh
📋 Dashboard Menu
text
Copy


🛡️ Security & Permissions
Uses termux-setup-storage to securely access shared storage.

 IMPORTANT - Does not require root, but supports tsu if available.

Runs system-friendly commands only — no unsafe modifications.

📚 Credits
Developed by: Mr Nova (@MrNova420)

Script Engineered for: Personal projects & community personal device performance montoring/boost needs


📃 License
This project is open-source and free to use under the MIT License.

🙌 Support & Contributions
Found a bug or want to contribute?
Open an issue or submit a pull request on GitHub!

💬 Feel free to share your experience or suggest features.

vbnet
Copy
Edit

---

