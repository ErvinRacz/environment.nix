# Preface

This manual describes how to install, use and extend NixOS, a Linux distribution based on the purely functional package management system [Nix](https://nixos.org/nix), that is composed using modules and packages defined in the [Nixpkgs](https://nixos.org/nixpkgs) project.

# Installation

This section describes how to obtain, install, and configure NixOS for first-time use.

## Obtaining NixOS

NixOS ISO images can be downloaded from the [NixOS download page](https://nixos.org/nixos/download.html). There are a number of installation options. In this manual we will assume that the chosen option is `Minimal ISO image (64bit)`.
You can burn it on a USB stick with:

```sh
sudo dd bs=4M if=Downloads/nixos-minimal-20.09.iso of=/dev/sdb conv=fdatasync
```

## Installing NixOS

### Booting the system

NixOS can be installed on BIOS or UEFI systems. In this manual we will assume that the chosen option is UEFI. The procedure for a UEFI installation is by and large the same as a BIOS installation.

The installation media contains a basic NixOS installation. When it’s finished booting, it should have detected most of your hardware.

The NixOS manual is available by running `nixos-help`.

You are logged-in automatically as `nixos`. The `nixos` user account has an empty password so you can use `sudo` without a password.

If the text is too small to be legible, try `setfont ter-v32n` to increase the font size.

#### Networking in the installer

The boot process should have brought up networking (check `ip a`). Networking is necessary for the installer, since it will download lots of stuff (such as source tarballs or Nixpkgs channel binaries). It’s best if you have a DHCP server on your network. Otherwise configure networking manually using `ifconfig`.

To manually configure the wifi on the minimal installer, run `wpa_supplicant -B -i interface -c <(wpa_passphrase 'SSID' 'key')`.

### Partitioning and formatting

The NixOS installer doesn’t do any partitioning or formatting, so you need to do that yourself.

The NixOS installer ships with multiple partitioning tools. The examples below use `parted`, but also provides `fdisk`, `gdisk`, `cfdisk`, and `cgdisk`.

#### UEFI (GPT)

Here's an example partition scheme for UEFI, using `/dev/sda` as the device.

> :warning: You can safely ignore parted's informational message about needing to update /etc/fstab.

1. Create a GPT partition table.

```sh
# parted /dev/sda -- mklabel gpt
```

2. Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.

```sh
# parted /dev/sda -- mkpart primary 512MiB -8GiB
```

3. Next, add a swap partition. The size required will vary according to needs, here a 8GiB one is created.

```sh
# parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
```

> :warning: The swap partition size rules are no different than for other Linux distributions.

4. Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its `/boot` partition. It uses the initially reserved 512MiB at the start of the disk.

```sh
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- set 3 esp on
```

Once complete, you can follow with Section 2.2.3, “Formatting”.

#### Formatting

Use the following commands:

- For initialising Ext4 partitions: `mkfs.ext4`. It is recommended that you assign a unique symbolic label to the file system using the option `-L label`, since this makes the file system configuration independent from device changes. For example:

```sh
# mkfs.ext4 -L nixos /dev/sda1
```

- For creating swap partitions: `mkswap`. Again it’s recommended to assign a label to the swap partition: `-L label`. For example:

```sh
# mkswap -L swap /dev/sda2
```

- For creating boot partitions: `mkfs.fat`. Again it’s recommended to assign a label to the boot partition: `-n label`. For example:

```sh
# mkfs.fat -F 32 -n boot /dev/sda3
```

- For creating LVM volumes, the LVM commands, e.g., `pvcreate`, `vgcreate`, and `lvcreate`.
- For creating software RAID devices, use `mdadm`.

> :warning: (LVM Note): you can wipe out the old partition information with `wipefs`:
>
> ```sh
> # wipefs -a /dev/sdd
> /dev/sdd: 2 bytes were erased at offset 0x000001fe (dos): 55 aa
> /dev/sdd: calling ioclt to re-read partition table: Success
> ```

> :warning: (LVM Note): you can create a singe logical volume using all spaces available in volume group:
>
> ```sh
> # lvcreate -n NAME -l 100%FREE vg0
> ```

### Installing

1. Mount the target file system on which NixOS should be installed on `/mnt`, e.g.

```sh
# mount /dev/disk/by-label/nixos /mnt
```

2. Mount the boot file system on /mnt/boot, e.g.

```sh
# mkdir -p /mnt/boot
# mount /dev/disk/by-label/boot /mnt/boot
```

3. If your machine has a limited amount of memory, you may want to activate swap devices now (`swapon device`). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.

```sh
# swapon /dev/sda2
```

4. You now need to create a file `/mnt/etc/nixos/configuration.nix` that specifies the intended configuration of the system. This is because NixOS has a declarative configuration model: you create or edit a description of the desired configuration of your system, and then NixOS takes care of making it happen. The syntax of the NixOS configuration file is described [here](https://nixos.org/manual/nixos/stable/index.html#sec-configuration-syntax), while a list of available configuration options is [here](https://nixos.org/manual/nixos/stable/options.html). A minimal example is shown [here](https://nixos.org/manual/nixos/stable/index.html#ex-config).

The command `nixos-generate-config` can generate an initial configuration file for you:

```sh
# nixos-generate-config --root /mnt
```

You should then edit /mnt/etc/nixos/configuration.nix to suit your needs:

```sh
# nano /mnt/etc/nixos/configuration.nix
```

You must set the option [`boot.loader.systemd-boot.enable`](https://nixos.org/manual/nixos/stable/options.html#opt-boot.loader.systemd-boot.enable) to `true`. `nixos-generate-config` should do this automatically for new configurations when booted in UEFI mode.

You may want to look at the options starting with [`boot.loader.efi`](https://nixos.org/manual/nixos/stable/options.html#opt-boot.loader.efi.canTouchEfiVariables) and [`boot.loader.systemd`](https://nixos.org/manual/nixos/stable/options.html#opt-boot.loader.systemd-boot.enable) as well.

If there are other operating systems running on the machine before installing NixOS, the [`boot.loader.grub.useOSProber`](https://nixos.org/manual/nixos/stable/options.html#opt-boot.loader.grub.useOSProber) option can be set to true to automatically add them to the grub menu.

While wifi is supported on the installation image, it is not enabled by default in the configuration generated by `nixos-generate-config`.
To facilitate network configuration, some desktop environments use `NetworkManager`. You can enable NetworkManager by setting:

```
networking.networkmanager.enable = true;
```

All users that should have permission to change network settings must belong to the `networkmanager` group:

```
users.users.alice.extraGroups = [ "networkmanager" ];
```

`NetworkManager` is controlled using either `nmcli` or `nmtui` (curses-based terminal user interface). See their manual pages for details on their usage.
By enabling programs.nm-applet.enable, the graphical applet will be installed and will launch automatically when the graphical session is started.

> :warning: `networking.networkmanager` and `networking.wireless` (WPA Supplicant) don't need to be used together

Another critical option is `fileSystems`, specifying the file systems that need to be mounted by NixOS. However, you typically don’t need to set it yourself, because `nixos-generate-config` sets it automatically in `/mnt/etc/nixos/hardware-configuration.nix` from your currently mounted file systems. (The configuration file `hardware-configuration.nix` is included from `configuration.nix` and will be overwritten by future invocations of `nixos-generate-config`; thus, you generally should not modify it.)

> :warning: Depending on your hardware configuration or type of file system, you may need to set the option `boot.initrd.kernelModules` to include the kernel modules that are necessary for mounting the root file system, otherwise the installed system will not be able to boot. (If this happens, boot from the installation media again, mount the target file system on `/mnt`, fix `/mnt/etc/nixos/configuration.nix` and rerun `nixos-install`.) In most cases, `nixos-generate-config` will figure out the required modules. 5. Do the installation:

```sh
# nixos-install
```

This will install your system based on the configuration you provided. If anything fails due to a configuration problem or any other issue (such as a network outage while downloading binaries from the NixOS binary cache), you can re-run `nixos-install` after fixing your configuration.nix.

As the last step, `nixos-install` will ask you to set the password for the root user, e.g.

```sh
setting root password...
Enter new UNIX password: ***
Retype new UNIX password: ***
```

> :warning: For unattended installations, it is possible to use `nixos-install --no-root-passwd` in order to disable the password prompt entirely.

6. If everything went well:

```sh
# reboot
```

7. You should now be able to boot into the installed NixOS. The GRUB boot menu shows a list of _available configurations_ (initially just one). Every time you change the NixOS configuration, a new item is added to the menu. This allows you to easily roll back to a previous configuration if something goes wrong.

You should log in and change the `root` password with `passwd`.

You’ll probably want to create some user accounts as well, which can be done with `useradd`:

```sh
$ useradd -c 'Eelco Dolstra' -m eelco
$ passwd eelco
```

You may also want to install some software. For instance,

```sh
$ nix-env -qaP \*
```

shows what packages are available, and

```sh
nix-env -f '<nixpkgs>' -iA w3m
```

installs the `w3m` browser.
