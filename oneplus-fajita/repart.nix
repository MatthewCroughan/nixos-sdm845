{
  modulesPath,
  pkgs,
  config,
  lib,
  ...
}:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  imports = [ "${modulesPath}/image/repart.nix" ];
  boot.loader.grub.enable = false;

  # Probably necessary for root resize
  systemd.repart.enable = true;
  systemd.repart.partitions."03-root".Type = "root";
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems.ext4 = true;

  fileSystems."/".device = lib.mkForce "/dev/disk/by-label/nixos";
  fileSystems."/".fsType = lib.mkForce "ext4";
  #  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-label/ESP";
  #  fileSystems."/boot".fsType = lib.mkForce "vfat";
  image.repart = {
    name = "image";
    split = true;
    compression.enable = true;
    partitions = {
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        # /boot now contains what used to be in the ESP
        contents = {
          "/boot/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/boot/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
            "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          "/boot/loader/loader.conf".source = pkgs.writeText "loader.conf" ''
            timeout 5
            console-mode keep
          '';
          "/boot/loader/entries/shell.conf".source = pkgs.writeText "shell.conf" ''
            title  EDK2 UEFI Shell
            efi    /EFI/EDK2-UEFI-SHELL/SHELL.EFI
          '';
        };
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
          SplitName = "root";
          GrowFileSystem = true;
        };
      };
    };
  };
}
