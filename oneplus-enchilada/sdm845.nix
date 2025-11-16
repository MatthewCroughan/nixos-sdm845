{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.callPackage ./kernel.nix {
      src = inputs.linux;
    }
  );
  boot.kernelPatches = [
    {
      name = "disable-stuff";
      patch = null;
      structuredExtraConfig = {
        TOUCHSCREEN_FTM4 = lib.mkForce lib.kernel.no;
        SND_SOC_MAX98512 = lib.mkForce lib.kernel.no;
      };
    }
  ];

}
