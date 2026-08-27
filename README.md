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
* **Default `.exe` Association:** Opens `.exe`, `.msi`, `.bat` with Wine instead of Bottles.
* **NVIDIA DLSS & NVAPI:** Injects `PROTON_ENABLE_NVAPI=1` and DXVK filter flags in `/etc/environment`.

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
