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
    url = "https://gitlab.postmarketos.org/tauchgang/u-boot.git";
    rev = "540db1c376fe304c423964809428ba0a0d1db378";
  };
#  extraConfig = ''
#    CONFIG_CMD_HASH=y
#    CONFIG_CMD_BLKMAP=y
#    CONFIG_BLKMAP=y
#    CONFIG_CMD_UFETCH=y
#    CONFIG_CMD_SELECT_FONT=y
#    CONFIG_VIDEO_FONT_16X32=y
#  '';
  prePatch = ''
    #rm dts/upstream/src/arm64/qcom/sdm845-oneplus-enchilada.dts
    #cp ${./qcom-phone.env} board/qualcomm/qcom-phone.env
    #cp -r ${./dts.dts} dts/upstream/src/arm64/qcom/sdm845-oneplus-common.dtsi
    #cp -r ${./fajita.dts} dts/upstream/src/arm64/qcom/sdm845-oneplus-fajita.dts
    #cp -r ${inputs.linux}/include/dt-bindings/input/qcom,spmi-haptics.h dts/upstream/include/dt-bindings/input
    #cp -r ${inputs.linux}/include/dt-bindings/sound/qcom,q6voice.h dts/upstream/include/dt-bindings/sound
    #cp -r ${inputs.linux}/include/uapi/linux/input-event-codes.h dts/upstream/include/dt-bindings/input/linux-event-codes.h
    #chmod -R +w dts/upstream/src/arm64/
  '';
  extraMakeFlags = [ "DEVICE_TREE=qcom/sdm845-oneplus-fajita" ];
  defconfig = "qcom_defconfig qcom-phone.config tauchgang.config";
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
    "dts/upstream/src/arm64/qcom/sdm845-oneplus-fajita.dtb"
  ];
}
