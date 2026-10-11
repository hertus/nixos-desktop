# NixOS Installation Guide (GUI Live Boot ISO)

This manual guides you step-by-step through installing this repository's configuration onto bare metal using the official **NixOS Graphical Live ISO (GNOME or Plasma)**.

It covers two setup workflows:
- **Scenario A (Recommended for this repo)**: Encrypted Btrfs on LUKS + TPM 2.0 auto-unlock (`custom.storage.encryption.enable = true`).
- **Scenario B**: Calamares Graphical Installer for standard partition setups (`custom.storage.encryption.enable = false`).

---

## 1. Preparation

### 1.1 Download & Flash Live ISO
1. Download the **NixOS Graphical ISO** (Plasma or GNOME edition) from [nixos.org/download](https://nixos.org/download.html).
2. Flash it onto a USB thumb drive using [Rufus](https://rufus.ie/) (in DD mode) or [BalenaEtcher](https://etcher.balena.io/).

### 1.2 BIOS / UEFI Settings
- **UEFI Mode**: Enabled (CSM / Legacy boot disabled).
- **Secure Boot**: Temporarily disabled during initial installation (can be enrolled later with `lanzaboote`).
- **SATA Mode**: AHCI (disable Intel RST / RAID if present on Dell laptops).
- **Security / TPM**: Ensure **Intel PTT** (Platform Trust Technology) or **AMD fTPM** (TPM 2.0) is enabled in BIOS.

---

## 2. Boot into the Live GUI Environment

1. Insert the USB drive and boot the machine (press `F12` on Dell, `F11`/`F12`/`Del` on custom AMD motherboards).
2. Select **NixOS Graphical Installer**.
3. Once booted into the live desktop, connect to Wi-Fi using the system tray network icon.
4. Open the **Terminal** application (Konsole or GNOME Terminal).

---

## 3. Storage Setup

Open a root shell:
```bash
sudo -i
```

Identify your target NVMe / SSD disk name:
```bash
lsblk
```
> In the commands below, we assume the target disk is `/dev/nvme0n1`. If your disk is `/dev/sda`, adapt accordingly.

---

### Scenario A: Encrypted LUKS + Btrfs Layout (Matching `custom.storage.encryption`)

#### 3.A.1 Partition the Disk
Create two partitions: a `512MB` UEFI boot partition and the encrypted system container partition:
```bash
# Wipe partition table
sgdisk --zap-all /dev/nvme0n1

# 1: EFI System Partition (ESP) - 512MB with partition label 'boot'
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:boot /dev/nvme0n1

# 2: LUKS Root Partition - Rest of disk with partition label 'cryptroot'
sgdisk -n 2:0:0 -t 2:8309 -c 2:cryptroot /dev/nvme0n1
```

#### 3.A.2 Format the Boot Partition
```bash
mkfs.vfat -F 32 -n boot /dev/disk/by-partlabel/boot
```

#### 3.A.3 Setup LUKS Container
```bash
# Encrypt partition (enter a strong recovery passphrase)
cryptsetup luksFormat --type luks2 /dev/disk/by-partlabel/cryptroot

# Open the container mapping it to 'cryptroot'
cryptsetup open /dev/disk/by-partlabel/cryptroot cryptroot
```

#### 3.A.4 Format Btrfs & Create Subvolumes
```bash
# Format root container with Btrfs
mkfs.btrfs -L nixos /dev/mapper/cryptroot

# Mount root temporarily to create subvolumes
mount /dev/mapper/cryptroot /mnt

# Create the standard subvolume layout (@, @home, @nix)
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix

umount /mnt
```

#### 3.A.5 Mount Subvolumes to Target `/mnt`
```bash
# Mount root subvolume
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt

# Create and mount mountpoints
mkdir -p /mnt/{home,nix,boot}
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o fmask=0077,dmask=0077 /dev/disk/by-partlabel/boot /mnt/boot
```

---

### Scenario B: Standard Non-Encrypted Partitioning (Alternative)

If you prefer using the Calamares GUI installer to partition the disk:
1. Run the graphical installer on desktop.
2. Complete disk partitioning and user setup through the GUI.
3. In `configuration.nix`, keep `custom.storage.encryption.enable = false;`.
4. Skip directly to **Section 4**.

---

## 4. Clone Your Configuration & Hardware Probe

### 4.1 Generate Hardware Configuration
Generate the machine-specific hardware probes for your current system:
```bash
nixos-generate-config --root /mnt
```
This generates `/mnt/etc/nixos/hardware-configuration.nix` detecting your disk UUIDs, kernel modules, and CPU topology.

### 4.2 Clone This Repository
Clone your GitHub repo into the target `/mnt/etc/nixos` directory:
```bash
cd /mnt/etc/nixos

# Backup the generated default configuration.nix (keep hardware-configuration.nix!)
mv configuration.nix configuration.nix.orig

# Clone repository files directly into /mnt/etc/nixos
git clone https://github.com/<YOUR-USERNAME>/nixos-desktop.git repo
cp -r repo/* .
rm -rf repo
```

---

## 5. Machine Tailoring Before Installing

Open [`configuration.nix`](./configuration.nix) in an editor:
```bash
nano /mnt/etc/nixos/configuration.nix
```

### 5.1 Set Hostname
```nix
networking.hostName = "nixos-workstation"; # or "nixos-laptop"
```

### 5.2 Select Hardware Profile
- For the **AMD Workstation**:
  ```nix
  custom.hardware.profile = "amd-workstation";
  ```
- For the **Dell Intel Evo Laptop**:
  ```nix
  custom.hardware.profile = "intel-laptop";
  ```

### 5.3 Verify Storage Configuration
- If using **Scenario A (LUKS + Btrfs)**:
  ```nix
  custom.storage.encryption = {
    enable = true;
    tpmAutoUnlock = true;
    device = "/dev/disk/by-partlabel/cryptroot";
  };
  ```
- If using **Scenario B (Standard/Calamares)**:
  ```nix
  custom.storage.encryption.enable = false;
  ```

### 5.4 Define Initial User Account
Ensure you have a user with `sudo` permissions defined. If not already present in your modules:
```nix
users.users.<your-username> = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
};
```

---

## 6. Install NixOS

Run the installation script:
```bash
nixos-install
```

You will be prompted to set the `root` user password.

Set password for your regular user:
```bash
nixos-enter --root /mnt -c 'passwd <your-username>'
```

---

## 7. TPM 2.0 Auto-Unlock Binding (Scenario A Only)

If you enabled `tpmAutoUnlock = true`, enroll your TPM 2.0 chip with the LUKS keyslot now so your PC unlocks automatically at boot:

```bash
# Enroll TPM 2.0 PCR registers (PCR 0+7 protects boot firmware integrity)
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/cryptroot
```

Verify keyslots (you should see a `tpm2` token bound):
```bash
cryptsetup luksDump /dev/disk/by-partlabel/cryptroot
```

---

## 8. Reboot & Verification

Unmount all filesystems and restart:
```bash
umount -R /mnt
cryptsetup close cryptroot # Only for Scenario A
reboot
```

Remove the USB thumb drive when the screen goes blank.

---

## 9. Post-Installation First Steps

Log into your KDE Plasma 6 desktop:

1. **Verify WireGuard / NetBird VPN**:
   ```bash
   netbird up
   ```

2. **Verify Hardware Acceleration**:
   - AMD Workstation: `radeontop` or `vulkaninfo | grep deviceName`
   - Intel Laptop: `intel_gpu_top` or `vainfo`

3. **Check Libvirt / Windows 11 VM Setup**:
   - Open **Virtual Machine Manager** (`virt-manager`).
   - Confirm virtual network `default` is active.
   - VirtIO drivers ISO is available at:
     `/run/current-system/sw/share/virtio-win/virtio-win.iso`

4. **Biometric Face Login Enrollment (Optional)**:
   ```bash
   sudo howdy add
   sudo howdy test
   ```

