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
#    ./kmod1.nix
#    ./kmod2.nix
  ];

      boot.initrd.systemd.initrdBin = [ pkgs.multipath-tools ];

      boot.initrd.services.udev.rules = ''
        SUBSYSTEM=="block", ACTION!="remove", ENV{ID_PART_ENTRY_NAME}=="userdata", RUN+="${pkgs.multipath-tools}/bin/kpartx -afs /dev/%k"
      '';

      boot.blacklistedKernelModules = [
    #    "qcom_q6v5_pas"
        "qcrypto"
      ];
      boot.initrd.includeDefaultModules = false;
      boot.initrd.systemd.tpm2.enable = false; # This also pulls in some modules our kernel is not build with.
      hardware.enableRedistributableFirmware = true;
  boot.initrd.kernelModules = [
    # Testing
    "pmic_glink"
    "ufs-qcom"
    "phy-qcom-qmp-combo"
    "phy-qcom-qmp-ufs"
    "phy_qcom_qmp_usb"
#    "qcom_spmi_haptics"

    "i2c_qcom_geni"
    "rmi_core"
    "rmi_i2c"

    "sd_mod"
    "scsi_mod"

    "dm_mod"

    "ufs-qcom"
    "phy-qcom-qmp-ufs"

#    "panel-samsung-sofef00"
#    "simpledrm"
#    "pmic_glink"
##    "drm_mipi_dsi"
##    "msm"
#    "gpucc_sdm845"
##    "dispcc_sdm845"
#    "clk-qcom"
  ];

#  boot.extraModprobeConfig = ''
#    softdep msm pre: panel-samsung-sofef00 gpucc_sdm845 dispcc_sdm845
#  '';


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

  boot.consoleLogLevel = 8;

  hardware.firmware = [ firmware ];

  hardware.deviceTree.overlays = [
    {
      name = "enable-usb";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "oneplus,fajita";
          fragment@0 {
            target = <&usb_1_dwc3>;
            __overlay__ {
              dr_mode = "host";
            };
          };
        };
      '';
    }
  ];


  # Maybe we should throw an assertion in nixpkgs if you are using systemd-boot
  # but you don't use vmlinuz.efi/zinstall like this
  nixpkgs.hostPlatform = lib.recursiveUpdate (lib.systems.elaborate "aarch64-linux") {
    linux-kernel.target = "vmlinuz.efi";
    linux-kernel.installTarget = "zinstall";
  };
#  boot.kernelPackages = pkgs.linuxPackages_testing;
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
        SDM_DISPCC_845  = lib.mkForce lib.kernel.module;
        SDM_GPUCC_845  = lib.mkForce lib.kernel.module;
#        ARCH_RENESAS = lib.mkForce lib.kernel.no;
#        ARCH_ROCKCHIP = lib.mkForce lib.kernel.no;
#        ROCKCHIP_DW_HDMI_QP = lib.mkForce lib.kernel.unset;
#        IMX_REMOTEPROC = lib.mkForce lib.kernel.no;
      };
    }
  ];

}
