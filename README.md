#### You have a new phone from eBay
1. Boot up the stock android OS
2. Ensure it is running at least 9.x of OxygenOS (the stock Android version), if not then update to the latest.

#### Enable Developer Options
1. Go to Settings → About Phone
2. Tap "Build Number" 7 times (After success, it should print "you are now a developer"
3. Go back to Settings → Developer Options (This is kind of hidden, so look hard)
4. Enable "USB Debugging"
5. Enable "OEM Unlocking"


#### Unlock the Bootloader

1. `nix-shell -p android-tools`
2. `adb devices` (You should see your device, you should also see "Allow USB Debugging" on the device when you execute this. Authorize this device)
3. `adb -d reboot bootloader` (Device will reboot into ABL (Arm Boot Loader), which has a green "START" at the top
4. `fastboot oem unlock` (The ABL wikk then ask for confirmation on the phone screen to unlock the device, you control this using volume keys and power button to confirm. The device will immediately reboot and your data will be erased)

#### Flash U-Boot to the Boot partition

1. `nix-shell -p android-tools`
2. `fastboot erase dtbo_a`
3. `fastboot erase dtbo_b`

`boot` is the name of the partition that exists on the mmc of the device
4. `fastboot flash boot --slot=all <uboot-boot-image>`
5. 





Check device connection:

Reboot to bootloader:

Unlock bootloader (this will erase all data!):

#+begin_src sh
#+end_src
