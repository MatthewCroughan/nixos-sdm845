# NixOS on OnePlus 6/6T (sdm845)

Install NixOS on a OnePlus 6 or 6T by flashing U-Boot and a NixOS image via fastboot.

| Device      | Codename    |
|-------------|-------------|
| OnePlus 6   | `enchilada` |
| OnePlus 6T  | `fajita`    |

The steps below use `fajita`. For the OnePlus 6, replace `fajita` with `enchilada` in all commands.

## You have a new phone from eBay

1. Boot up the stock Android OS.
2. Ensure it is running at least 9.x of OxygenOS (the stock Android version), if not then update to the latest.

## Prerequisites

### Android Tools

```sh
nix-shell -p android-tools
```

### aarch64 Builder

Building requires an `aarch64-linux` machine. Check your current system:

```sh
nix-instantiate --eval -E "builtins.currentSystem"
```

If this prints `"x86_64-linux"`, you need a remote builder. All `nix build` commands below accept a `--builders` flag:

```sh
--builders 'ssh-ng://nix-ssh@m2.localdomain aarch64-linux - 24 24 big-parallel'
```

Replace `nix-ssh@m2.localdomain` with your remote builder. See the [Nix manual](https://nix.dev/manual/nix/latest/advanced-topics/distributed-builds) for setup and details.

## 1. Prepare the Phone

### Enable Developer Options

1. Go to **Settings → About Phone**.
2. Tap **Build Number** 7 times. You should see *"You are now a developer"*.
3. Go to **Settings → Developer Options**.
4. Enable **USB Debugging**.
5. Enable **OEM Unlocking**.
6. Enable **Advanced Reboot**.

### Reboot to Bootloader

Hold the power button for 3 seconds and select **Bootloader**.

### Unlock the Bootloader

> **Warning:** This erases all data on the device.

```sh
fastboot oem unlock
```

Use the volume buttons to select and the power button to confirm the on-screen prompt. The device will reboot.

After the reboot, force-restart into the bootloader by holding **Volume Up + Volume Down + Power** for 10 seconds.

## 2. Flash U-Boot

Erase the vendor `dtbo` partitions:

```sh
fastboot erase dtbo
fastboot erase dtbo_a
fastboot erase dtbo_b
```

Build the U-Boot image:

```sh
nix build .#packages.aarch64-linux.sdm845-oneplus-fajita-uboot-bootimg -L
```

Flash it to the `boot` partition (both slots):

```sh
fastboot flash boot --slot=all result
```

## 3. Flash NixOS

Build the NixOS image:

```sh
nix build .#nixosConfigurations.sdm845-oneplus-fajita.config.system.build.image -L
```

Decompress and flash it to the `userdata` partition:

```sh
zstdcat result/image.raw.zst > /tmp/image.raw
fastboot flash userdata /tmp/image.raw
```

## 4. Boot

Use the volume buttons to select **Start** and confirm with the power button.

> **Note:** The bootloader has an internal counter that locks the phone after 5 failed boots. When this happens the phone boots straight into the Fastboot menu and selecting **Start** doesn't boot the system anymore.
>
> To fix this, re-flash the boot partition (step 2).
