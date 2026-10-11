#!/usr/bin/env bash
# ==============================================================================
# NixOS Partitioning & Mount Script (Encrypted Btrfs on LUKS + TPM 2.0 layout)
# Matches `custom.storage.encryption` in nixos-desktop configuration.
#
# Usage:
#   sudo ./scripts/partition-and-mount.sh /dev/nvme0n1
# ==============================================================================

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (e.g. sudo bash partition-and-mount.sh <DISK>)"
fi

# Ensure disk parameter was passed
if [[ $# -lt 1 ]]; then
    echo "Usage: sudo $0 <TARGET_DISK>"
    echo "Example: sudo $0 /dev/nvme0n1"
    echo "Example: sudo $0 /dev/sda"
    echo ""
    echo "Available block devices:"
    lsblk -d -p -n -l -o NAME,SIZE,MODEL,TYPE | grep -E "disk"
    exit 1
fi

TARGET_DISK="$1"

# Validate that the target device exists and is a block device
if [[ ! -b "$TARGET_DISK" ]]; then
    log_error "Device '$TARGET_DISK' does not exist or is not a block device!"
fi

echo -e "${RED}==============================================================================${NC}"
echo -e "${RED}                           DANGER: DATA LOSS WARNING                          ${NC}"
echo -e "${RED}==============================================================================${NC}"
echo "Target disk: $TARGET_DISK"
lsblk "$TARGET_DISK"
echo ""
echo "ALL DATA ON '$TARGET_DISK' WILL BE PERMANENTLY ERASED!"
read -rp "Type 'YES' (case-sensitive) to proceed: " CONFIRMATION

if [[ "$CONFIRMATION" != "YES" ]]; then
    log_warn "Installation aborted by user."
    exit 0
fi

# 1. Unmount and clean up any existing mounts / device mappings
log_info "Cleaning up existing mounts and device-mapper containers..."
umount -R /mnt 2>/dev/null || true
if [ -e /dev/mapper/cryptroot ]; then
    cryptsetup close cryptroot 2>/dev/null || true
fi

# 2. Partitioning with sgdisk
log_info "Wiping disk and creating GPT partition table on $TARGET_DISK..."
sgdisk --zap-all "$TARGET_DISK"
wipefs -a "$TARGET_DISK"

log_info "Creating EFI boot partition (512MB) labeled 'boot'..."
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:boot "$TARGET_DISK"

log_info "Creating LUKS container partition (remaining space) labeled 'cryptroot'..."
sgdisk -n 2:0:0 -t 2:8309 -c 2:cryptroot "$TARGET_DISK"

# Wait for kernel to refresh partition table
partprobe "$TARGET_DISK"
sleep 2

BOOT_PART="/dev/disk/by-partlabel/boot"
CRYPT_PART="/dev/disk/by-partlabel/cryptroot"

if [[ ! -e "$BOOT_PART" || ! -e "$CRYPT_PART" ]]; then
    log_error "Partition labels '/dev/disk/by-partlabel/{boot,cryptroot}' not found. Check partprobe/udev."
fi

# 3. Format EFI Partition
log_info "Formatting EFI system partition as FAT32..."
mkfs.vfat -F 32 -n boot "$BOOT_PART"
log_success "Boot partition formatted."

# 4. LUKS2 Encryption Setup
echo ""
log_info "================================================================="
log_info "Setting up LUKS2 encryption container on $CRYPT_PART"
log_info "Please enter your recovery passphrase when prompted by cryptsetup."
log_info "================================================================="
cryptsetup luksFormat --type luks2 --pbkdf argon2id "$CRYPT_PART"

log_info "Opening LUKS container as '/dev/mapper/cryptroot'..."
cryptsetup open "$CRYPT_PART" cryptroot
log_success "LUKS container decrypted and mapped."

# 5. Format Btrfs & Create Subvolumes
log_info "Formatting Btrfs filesystem on '/dev/mapper/cryptroot'..."
mkfs.btrfs -f -L nixos /dev/mapper/cryptroot

log_info "Creating Btrfs subvolumes (@, @home, @nix)..."
mkdir -p /mnt_tmp
mount /dev/mapper/cryptroot /mnt_tmp

btrfs subvolume create /mnt_tmp/@
btrfs subvolume create /mnt_tmp/@home
btrfs subvolume create /mnt_tmp/@nix

umount /mnt_tmp
rmdir /mnt_tmp
log_success "Btrfs subvolumes created."

# 6. Mount Subvolumes to /mnt
log_info "Mounting subvolumes to /mnt..."
mkdir -p /mnt
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{home,nix,boot}
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o fmask=0077,dmask=0077 "$BOOT_PART" /mnt/boot

log_success "Filesystem hierarchy successfully mounted at /mnt:"
lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,SIZE "$TARGET_DISK"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}             Disk setup complete! Next steps to run in Live ISO:              ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo "1. Generate hardware config:"
echo "     nixos-generate-config --root /mnt"
echo ""
echo "2. Clone this repo into /mnt/etc/nixos:"
echo "     cd /mnt/etc/nixos"
echo "     mv configuration.nix configuration.nix.orig"
echo "     git clone https://github.com/<YOUR-USER>/nixos-desktop.git repo"
echo "     cp -r repo/* ."
echo "     rm -rf repo"
echo ""
echo "3. Run installation:"
echo "     nixos-install"
echo ""
echo "4. (Optional) Enroll TPM 2.0 auto-unlock:"
echo "     systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/cryptroot"
echo "=============================================================================="

