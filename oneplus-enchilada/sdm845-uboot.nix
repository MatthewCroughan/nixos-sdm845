# https://docs.u-boot.org/en/latest/board/qualcomm/board.html
{
  buildUBoot,
  xxd,
  bison,
  flex,
  openssl,
  gnutls,
  fetchgit,
  python3Packages,
  android-tools,
  fetchpatch2,
  inputs,
}:
buildUBoot {
  version = "master";
  src = builtins.fetchGit {
    url = "https://github.com/u-boot/u-boot.git";
    rev = "92dcb3ad5d98f494b2448a7345e1cb7eefa50278";
  };
  extraConfig = ''
    CONFIG_CMD_HASH=y
    CONFIG_CMD_UFETCH=y
    CONFIG_CMD_SELECT_FONT=y
    CONFIG_VIDEO_FONT_8X16=y
  '';
  prePatch = ''
    cat configs/qcom_defconfig board/qualcomm/qcom-phone.config > f
    mv f configs/qcom_defconfig

    rm dts/upstream/src/arm64/qcom/sdm845-oneplus-fajita.dts

    cp -r ${./dts.dts} dts/upstream/src/arm64/qcom/sdm845-oneplus-common.dtsi
    cp -r ${./enchilada.dts} dts/upstream/src/arm64/qcom/sdm845-oneplus-enchilada.dts
    cp -r ${./dts.dts} dts/upstream/src/arm64/qcom/sdm845-oneplus-common.dtsi
    cp -r ${inputs.linux}/include/dt-bindings/input/qcom,spmi-haptics.h dts/upstream/include/dt-bindings/input
    cp -r ${inputs.linux}/include/dt-bindings/sound/qcom,q6voice.h dts/upstream/include/dt-bindings/sound
    cp -r ${inputs.linux}/include/uapi/linux/input-event-codes.h dts/upstream/include/dt-bindings/input/linux-event-codes.h

    chmod -R +w dts/upstream/src/arm64/
  '';
  extraMakeFlags = [ "DEVICE_TREE=qcom/sdm845-oneplus-enchilada" ];
  defconfig = "qcom_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  nativeBuildInputs = [
    xxd
    bison
    flex
    openssl
    gnutls
    android-tools
  ];
  filesToInstall = [
    "u-boot*"
    "dts/upstream/src/arm64/qcom/sdm845-oneplus-enchilada.dtb"
  ];
}
