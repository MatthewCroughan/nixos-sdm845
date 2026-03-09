{ lib, pkgs, ... }:
{
  imports = [
    ./repart.nix
    ./wireless.nix
    ./bullshit.nix
  ];
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };
  users.users.root.password = "default";
  boot.kernelParams = [ "console=ttyGS0,115200" ];
  boot.kernelPatches = [
    {
      name = "usb-otg-serial";
      patch = null;
      structuredExtraConfig = {
        USB_G_SERIAL = lib.mkForce lib.kernel.yes;
        U_SERIAL_CONSOLE = lib.mkForce lib.kernel.yes;
        USB_U_SERIAL = lib.mkForce lib.kernel.yes;
      };
    }
  ];
}
