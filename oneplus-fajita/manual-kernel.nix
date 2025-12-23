{
  pkgs,
  lib,
  src,
  ...
}:
(pkgs.linuxKernel.manualConfig rec {
  version = "6.19.0-rc1-next-20251219-sdm845";
  inherit src;
  modDirVersion = lib.versions.pad 3 version;
  configfile = ./config-postmarketos-qcom-sdm845.aarch64;
  allowImportFromDerivation = false;
}).overrideAttrs
  (old: {
    postInstall = ''
      # For some reason the NixOS machiney wants these
      mkdir -p $modules/lib/modules/"$version"
      touch  $modules/lib/modules/"$version"/modules.order
      touch  $modules/lib/modules/"$version"/modules.builtin

      # Removes symbol maps to shave off a few megabytes
      rm $out/System.map
    '';
    passthru = old.passthru // {
        isModular = false;
      features = {
        isModular = false;
        efiBootStub = true;
      };
    };
  })

