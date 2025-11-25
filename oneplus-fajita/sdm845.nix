{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  firmware = pkgs.stdenvNoCC.mkDerivation {
    name = "firmware-oneplus-sdm845";
    src = pkgs.fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "firmware-oneplus-sdm845";
      rev = "176ca713448c5237a983fb1f158cf3a5c251d775";
      hash = "sha256-ZrBvYO+MY0tlamJngdwhCsI1qpA/2FXoyEys5FAYLj4=";
    };
    installPhase = ''
      cp -a . "$out"
      cd "$out/lib/firmware/postmarketos"
      find . -type f,l | xargs -i bash -c 'mkdir -p "$(dirname "../$1")" && mv "$1" "../$1"' -- {}
      cd "$out/usr"
      find . -type f,l | xargs -i bash -c 'mkdir -p "$(dirname "../$1")" && mv "$1" "../$1"' -- {}
      cd ..
      find "$out/lib/firmware/postmarketos" "$out/usr" | tac | xargs rmdir
    '';
    dontStrip = true;
    # not actually redistributable, but who cares
    meta.license = lib.licenses.unfreeRedistributableFirmware;
  };
in
{
  imports = [
    "${inputs.mobile-nixos}/modules/quirks/qualcomm/sdm845-modem.nix"
    "${inputs.mobile-nixos}/modules/quirks/audio.nix"
  ];
  hardware.enableRedistributableFirmware = true;
  mobile.quirks.qualcomm.sdm845-modem.enable = true;
  boot.initrd.kernelModules = [
    "i2c_qcom_geni"
    "rmi_core"
    "rmi_i2c"
    "qcom_spmi_haptics"
    "panel-samsung-sofef00"
    "msm"
  ];
  boot.kernelParams = [
    "iommu=soft"
    "clk_ignore_unused"
    "pd_ignore_unused"
    "arm64.nopauth"
    "console=ttyMSM0,115200"
    "console=tty0"
#    "dtb=/${config.hardware.deviceTree.name}"
  ];

  hardware.deviceTree.name = "qcom/sdm845-oneplus-fajita.dtb";

  boot.consoleLogLevel = 7;

  hardware.firmware = [ firmware ];

  # Maybe we should throw an assertion in nixpkgs if you are using systemd-boot
  # but you don't use vmlinuz.efi/zinstall like this
  nixpkgs.hostPlatform = lib.recursiveUpdate (lib.systems.elaborate "aarch64-linux") {
    linux-kernel.target = "vmlinuz.efi";
    linux-kernel.installTarget = "zinstall";
  };
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
