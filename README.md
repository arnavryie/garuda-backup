# 🐉 Garuda Linux - Lenovo LOQ Gaming & System Setup

[![Garuda Linux](https://img.shields.io/badge/Garuda_Linux-Dr460nized-purple.svg)](https://garudalinux.org)
[![Lenovo LOQ](https://img.shields.io/badge/Hardware-Lenovo_LOQ_(83DV)-red.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An all-in-one recovery, configuration, and optimization suite for **Garuda Linux** running on **Lenovo LOQ (Intel i7-13650HX + NVIDIA RTX 4060)** with dual NVMe SSDs.

---

## ⚡ Quick 1-Command Installation

On a fresh install of Garuda Linux, clone this repository and run the setup script:

```bash
git clone https://github.com/arnavryie/garuda-backup.git
cd garuda-backup
chmod +x install.sh storage/*.sh hardware/*.sh gaming/*.sh
./install.sh
```

---

## 📦 What This Repository Configures

### 1. 💽 Dual NVMe SSD & Dolphin File Manager
* Automatically detects the secondary NVMe SSD (`/dev/nvme0n1`), cleans leftover swap partitions, and resizes to the full **512 GB capacity**.
* Mounts permanently to `/mnt/Storage` via `/etc/fstab` with `noatime` performance flags.
* Creates convenient `~/Storage` and `/run/media/ryie/Storage` symlinks.
* Injects dedicated **System SSD (Crucial 500GB)** and **Storage SSD (Micron 512GB)** bookmarks directly into **Dolphin's Places sidebar**.

### 2. 🖱️ Lenovo LOQ Hardware & Touchpad Fixes
* Fixes the Lenovo `ELAN06FA` i2c-hid ACPI touchpad freezing bug by installing an auto-rebinding boot service (`/etc/systemd/system/touchpad-fix.service`).
* Enables multi-touch gestures autostart (`libinput-gestures`).

### 3. 🎮 Gaming, Steam, Wine & DirectX 12 (VKD3D)
* **Steam Wayland / NVIDIA Crash Fix:** Overrides Steam's desktop launcher with `-cef-disable-gpu` and disables discrete GPU forcing for the UI, permanently stopping the **"Unexpected Transport Error"** loop.
* **DirectX 11 & 12 in Wine:** Installs Valve's **VKD3D-Proton** and **DXVK** into `~/.wine` so modern DX12 games (*Ghost of Tsushima, Black Myth Wukong, etc.*) run out-of-the-box.
* **Wine `D:\` Drive Letter:** Maps `D:\` directly to `/mnt/Storage`.
* **NVIDIA DLSS & NVAPI:** Injects `PROTON_ENABLE_NVAPI=1` and DXVK filter flags in `/etc/environment`.
* **Persistent 100GB NVIDIA Shader Cache:** Configures `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1` and `100GB` cache limits in `/etc/environment`, `/etc/environment.d/`, and `/etc/profile.d/`, preventing the driver from deleting compiled DX12/Vulkan game shaders across reboots.
* **Low-Latency & Anti-Bufferbloat Network Stack:** Enables Google `BBR` congestion control, `fq_codel` queuing on Wi-Fi, and disables Wi-Fi power-save sleep states (`wifi.powersave = 2`), dropping gaming latency and packet loss on mobile hotspots.
* **Intel i7 CPU Performance Boot Service:** Persistent systemd service (`cpu-performance.service`) locking all 20 threads to maximum clock speeds right from boot.

### 4. 🖥️ Desktop & Workspace Dots Plasmoid
* **Workspace Dots (KDE Plasma 6 Fix):** Fixes the Hyprland-style workspace dots pager by integrating directly with native KWin DBus (`setCurrentDesktop`, `nextDesktop`, `previousDesktop`), restoring instant click and wheel desktop switching.
* **Win + Q Quick App Quit & Hover Focus (Hyprland Style):** Binds `Win + Q` (`Meta + Q`) to close/quit applications and enables instant `FocusFollowsMouse` so hovering over any app window allows closing it immediately without needing to click it first.
* **KDE Window Management & Focus:** Disables focus-stealing prevention and forces Picture-in-Picture windows to stay on top.

### 5. 📱 Apple iPhone USB Tethering & Dolphin AFC Integration
* **Apple Mobile Device Protocol (`usbmuxd`):** Configures and enables the `usbmuxd` socket daemon for native iPhone communication.
* **USB Ethernet (`ipheth`):** Autoloads `ipheth` via `/etc/modules-load.d/ipheth.conf` for instant, zero-latency wired tethering when Personal Hotspot is active.
* **Dolphin File & Photo Browsing (`ifuse` & `gvfs-afc`):** Installs Apple File Conduit backends so iPhones mount cleanly as removable storage devices in Dolphin.

### 6. 🎙️ Fifine Mic NoiseTorch Smart Battery Guard & Autostart
* **PipeWire 1.6+ LADSPA Sandbox Fix:** Injects `LADSPA_PATH` into `pipewire-pulse` systemd user service override, fixing `commandLoadModule -> No such entity` errors.
* **Dynamic Hardware & Power Management (`udev`):** Instant udev kernel hooks monitor AC charger connect/disconnect and Fifine USB hotplug events.
* **Zero Battery Drain Guarantee:** When operating on battery power OR when the Fifine microphone is disconnected, the service completely unloads NoiseTorch from PipeWire (0% CPU, 0 MB RAM, no background audio filtering loop). When plugged into AC power with the Fifine mic connected, it automatically restores the 95% threshold noise suppressor and sets it as the system's default source.

### 7. 🎨 Plasma Theme, Pinned Apps, Life OS & Thermal Sensors
* **Exact Desktop Theme & Layout:** Restores the `Scratchy` dark theme, color schemes, Aurorae window decorations, and exact panel heights/geometries.
* **Taskbar & Pinned Applications:** Instantly restores all 50 pinned apps and Edge PWAs (*ChatGPT, Claude, LeetCode, Upwork, WhatsApp, Telegram, Fiverr, YouTube Music, Obsidian, Antigravity IDE, Steam, ZapZap, etc.*) complete with high-resolution icons.
* **Life OS HUD & Workspace Dots:** Reinstalls custom plasmoids including **Life OS (J.A.R.V.I.S. Core 4.2)** and the Hyprland workspace dots pager.
* **Top Status Bar & Thermal Sensors:** Reconfigures CPU/GPU thermal monitors (`org.kde.olib.thermalmonitor`), memory meters, and system sensors on the top panel.

### 8. 💾 Dual-Tier Master Backup Architecture
* **Tier 1 (Cloud / GitHub Repository):** Houses all dotfiles, Plasma configurations, theme assets, custom plasmoids, `.desktop` launchers, package manifests, and installation scripts.
* **Tier 2 (Offline / Secondary NVMe SSD `/mnt/Storage/Garuda-Full-Backup`):** Automatically backs up all game saves (*Assassin's Creed Shadows & Black Flag, Ghost of Tsushima, Spider-Man, Wine Roaming/Local saves*), Steam userdata, personal documents, books, Obsidian vault, and the full 1.6GB icon packs. Survives laptop resets and OS wipes completely intact!
* **1-Click Backup:** Run `./backup-all.sh` anytime to take a complete live snapshot.
* **1-Click Restore:** Run `./restore-all.sh` to reincarnate your complete system.

---

## 🛠️ Manual Module Execution

If you only want to install specific components:

```bash
# Secondary SSD & Dolphin Places only
sudo ./storage/setup-storage.sh
./storage/install-dolphin.sh

# Lenovo Touchpad Fix only
sudo ./hardware/install-touchpad.sh

# Steam & Wine Gaming Fixes only
./gaming/setup-wine-gaming.sh
```

---

## 💻 Hardware Compatibility
* **Laptop:** Lenovo LOQ 15IRX9 / 15IAX9 (Model 83DV)
* **CPU:** 13th Gen Intel Core i7-13650HX
* **GPU:** NVIDIA GeForce RTX 4060 Mobile (105W TGP)
* **OS:** Garuda Linux (KDE Plasma 6, Wayland)
