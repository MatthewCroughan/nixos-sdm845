## You have a new phone from eBay

1. Boot up the stock android OS
2. Ensure it is running at least 9.x of OxygenOS (the stock Android version), if not then update to the latest.

### Enable Developer Options

1. Go to Settings → About Phone
2. Tap "Build Number" 7 times (After success, it should print "you are now a developer")
3. Go back to Settings → Developer Options (This is kind of hidden, so look hard)
4. Enable "USB Debugging"
5. Enable "OEM Unlocking"
6. Enable "Advanced Reboot"

Press power button (3s)

Select: "bootloader"

## Prerequisites

```sh
nix-shell -p android-tools
```

You need to have an arm-based machine or access to an arm builder.

```sh
nix-instantiate --eval -E "builtins.currentSystem"
>"x86_64-linux"
```

That means you need to setup a remote builder or a different machine.
Follow the nix manual for how to do that.

### Unlock the Bootloader

1. `fastboot oem unlock` (The ABL wikk then ask for confirmation on the phone screen to unlock the device, you control this using volume keys and power button to confirm. The device will immediately reboot and your data will be erased)
1. Use volume buttons to select, power button to confirm.
1. Press and hold: volume up + Volume down + power button (10s)

#### Flash U-Boot to the Boot partition

1. `fastboot erase dtbo`
2. `fastboot erase dtbo_a`
3. `fastboot erase dtbo_b`

delete some original vendor partitions

build the u-boot image

```sh
nix build .#packages.aarch64-linux.sdm845-oneplus-fajita-uboot-bootimg
```

```sh
fastboot flash boot --slot=all result
```

`boot` is the name of the partition that exists on the mmc of the device

Build the nixos image

```sh
nix build .#nixosConfigurations.sdm845-oneplus-fajita.config.system.build.image -L
# or remote build
nix build .#nixosConfigurations.sdm845-oneplus-fajita.config.system.build.image -L --builders 'ssh-ng://nix-ssh@m2.localdomain aarch64-linux - 24 24'
```

Connect the phone in fastboot mode (reboot to bootloader), then:

```bash
zstdcat -d result/image.raw.zst -o /tmp/image.raw
fastboot flash userdata /tmp/image.raw
```

Then reboot:

```steps
select "start" (via volume +/-)
confirm with power button
```

Note: After 5 failed boots you have to flash the boot partition again.
There is an internal increment counter that locks the phone.

Replace `nix-ssh@m2.localdomain` with your remote builder.

```sh
nix build .#packages.aarch64-linux.sdm845-oneplus-fajita-uboot-bootimg -L --builders 'ssh-ng://nix-ssh@m2.localdomain aarch64-linux - 24 24 big-parallel'
fastboot flash boot --slot=all result
```