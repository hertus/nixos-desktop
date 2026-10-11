# NixOS Maintenance & Update Manual

This guide explains how to manage, customize, and update a running NixOS system using this repository. It covers everyday workflows: pulling updates, testing and applying changes, rolling back, adding packages, and customizing settings.

---

## 1. Where Does the Configuration Live?

On a running system, the official NixOS configuration lives in:
```bash
/etc/nixos
```

Since this repository is managed with Git, `/etc/nixos` should be a clone of your repository (with `hardware-configuration.nix` preserved).

To check status:
```bash
cd /etc/nixos
git status
```

---

## 2. The 3 Core Rebuild Commands

Whenever you change any file in `/etc/nixos`, you use `nixos-rebuild` to evaluate and compile the new system generation:

| Command | What it does | When to use it |
| :--- | :--- | :--- |
| `sudo nixos-rebuild dry-build` | Evaluates syntax without building packages | Quick syntax and option checking |
| `sudo nixos-rebuild test` | Builds and activates the new system **temporarily** (does not add a bootloader entry) | Testing new settings (rebooting will return to the previous state) |
| `sudo nixos-rebuild switch` | Builds, activates immediately, and makes it the **default boot generation** | Applying permanent updates |
| `sudo nixos-rebuild boot` | Builds and sets as next boot generation without activating right now | Useful for kernel updates |

---

## 3. How to Update Your Running System from Git

When you or this assistant make commits to your GitHub repository:

```bash
# 1. Navigate to configuration directory
cd /etc/nixos

# 2. Pull latest configuration changes from GitHub
sudo git pull

# 3. Test build first to catch any errors
sudo nixos-rebuild test --show-trace

# 4. If everything looks good, make it permanent
sudo nixos-rebuild switch
```

---

## 4. How to Update All System Packages (`nix-channel` / Flakes)

NixOS packages are pinned to a channel or flake lock. To update all software packages (e.g. Brave, Kernel, KDE Plasma) to their latest versions:

```bash
# 1. Update package channels (fetch latest package definitions from nixos-24.11)
sudo nix-channel --update

# 2. Rebuild and activate the system with updated packages
sudo nixos-rebuild switch --upgrade
```

---

## 5. How to Add Additional Packages

Package definitions are decoupled into logical modules. Open the relevant file with `sudo nano` or your editor:

### 5.1 General User & System Applications
Open [`modules/packages/default.nix`](./modules/packages/default.nix):
```bash
sudo nano /etc/nixos/modules/packages/default.nix
```
Add any package from [search.nixos.org](https://search.nixos.org/packages) to the `environment.systemPackages` list:
```nix
environment.systemPackages = with pkgs; [
  # Utilities
  htop
  fastfetch
  tree
  ripgrep
  bat

  # Graphics / Audio tools
  gimp
  audacity
];
```

### 5.2 Hardware-Specific Packages
- For AMD tools (Vulkan, GPU monitors): edit [`modules/hardware/amd-workstation.nix`](./modules/hardware/amd-workstation.nix).
- For Intel tools (VA-API codecs, power tools): edit [`modules/hardware/intel-laptop.nix`](./modules/hardware/intel-laptop.nix).

### 5.3 VSCodium Extensions
Open [`modules/programs/vscodium.nix`](./modules/programs/vscodium.nix):
```nix
vscodeExtensions = with pkgs.vscode-extensions; [
  # Add officially packaged extensions here:
  rust-lang.rust-analyzer
  hashicorp.terraform
];
```

---

## 6. How to Add New System Settings & Services

### 6.1 Enabling a Common Service
You can enable services directly in [`modules/services/default.nix`](./modules/services/default.nix) or create a new module:

#### Example: Enable Syncthing
```nix
services.syncthing = {
  enable = true;
  user = "hertus";
  dataDir = "/home/hertus/Sync";
};
```

#### Example: Enable Flatpak
```nix
services.flatpak.enable = true;
```

#### Example: Change Default Shell to Zsh
In [`modules/users/hertus.nix`](./modules/users/hertus.nix):
```nix
programs.zsh.enable = true;
users.users.hertus.shell = pkgs.zsh;
```

---

## 7. How to Create a New Module File

To keep the repository clean and maintainable, group new functionality into a dedicated file:

1. Create the new file, e.g. `/etc/nixos/modules/services/nextcloud.nix`:
   ```nix
   { pkgs, ... }:

   {
     # Your configuration here
   }
   ```
2. Import it in [`modules/default.nix`](./modules/default.nix):
   ```nix
   imports = [
     # ...
     ./services/nextcloud.nix
   ];
   ```
3. Run `sudo nixos-rebuild switch`.

---

## 8. Safety & Rollbacks: Fixing Broken Configurations

NixOS creates a new, isolated "generation" on every rebuild. You can never get permanently locked out by a configuration typo.

### 8.1 Instant Rollback (Live System)
If an update causes an issue while booted:
```bash
# Roll back to the previous generation immediately
sudo nixos-rebuild --rollback switch
```

### 8.2 Rollback via Boot Menu
If the system will not boot:
1. Reboot the computer.
2. In the `systemd-boot` menu, select **NixOS - All configurations**.
3. Choose Generation $N-1$ (the previous working generation).
4. The system boots into the working state. Once logged in, fix the configuration in `/etc/nixos` and rebuild.

### 8.3 List Available Generations
```bash
nixos-rebuild list-generations
```

---

## 9. Disk Space & Garbage Collection

Every generation stores its packages in `/nix/store`. To free up disk space by cleaning up old generations:

```bash
# 1. Delete generations older than 14 days
sudo nix-collect-garbage --delete-older-than 14d

# 2. Optimize duplicate files in the nix store (hardlinking identical files)
sudo nix-store --optimize
```

