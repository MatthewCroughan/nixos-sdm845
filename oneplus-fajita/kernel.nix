{
  lib,
  buildLinux,
  fetchFromGitLab,
  fetchFromGitHub,
  ...
}@args:
let
  #src = fetchFromGitHub {
  #  owner = "sc7280-mainline";
  #  repo = "linux";
  #  rev = "7caee3e710ff6704cf98df690415790a0a6beda1";
  #  hash = "sha256-T1rTa6SkbDOPp36nn2DbIUdnfo48Hm4Dx6qh8ZKL95E=";
  #};
  src = args.src;
  #src = builtins.fetchGit {
  #  url = "https://github.com/MatthewCroughan/linux.git";
  #  rev = "2e6ed3b4c5c1c5e01862efcef8b94272900f2277";
  #};
  #src = fetchFromGitHub {
  #  owner = "matthewcroughan";
  #  repo = "linux";
  #  rev = "ba982ae273a30e9e29327276a992c99051661621";
  #  hash = "sha256-iqAvir+9Ui+uifXYoBAghCCepxBwRkV6T0f+ckoJfRM=";
  #};
  kernelVersion = rec {
    # Fully constructed string, example: "5.10.0-rc5".
    string = "${
      version + "." + patchlevel + "." + sublevel + (lib.optionalString (extraversion != "") extraversion)
    }";
    file = "${src}/Makefile";
    version = toString (builtins.match ".+VERSION = ([0-9]+).+" (builtins.readFile file));
    patchlevel = toString (builtins.match ".+PATCHLEVEL = ([0-9]+).+" (builtins.readFile file));
    sublevel = toString (builtins.match ".+SUBLEVEL = ([0-9]+).+" (builtins.readFile file));
    # rc, next, etc.
    extraversion = toString (builtins.match ".+EXTRAVERSION = ([a-z0-9-]+).+" (builtins.readFile file));
  };
  modDirVersion = "${kernelVersion.string}";
in
(buildLinux (
  args
  // {
    inherit src;
#    modDirVersion = "${modDirVersion}";
    modDirVersion = "6.19.0-rc1-next-20251219-sdm845";
    enableCommonConfig = true;
    preferBuiltIn = true;
     ignoreConfigErrors = true;
     defconfig = "defconfig sdm845.config";
    autoModules = false;
    version = "${modDirVersion}";
    extraMeta = {
      platforms = [ "aarch64-linux" ];
      hydraPlatforms = [ "" ];
    };
  }
  // (args.argsOverride or { })
)).overrideAttrs
  (old: {
#    patches = old.patches ++ (lib.filesystem.listFilesRecursive "${args.src}/debian/patches/sdm845");
    postUnpack = ''
      patchShebangs source/lib/tests/module/gen_test_kallsyms.sh
    '';
    NIX_CFLAGS_COMPILE = "-Wno-error=return-type -Wno-error=implicit-function-declaration -Wno-error=int-conversion";
  })
