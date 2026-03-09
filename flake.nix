{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    linux = {
      url = "https://codeberg.org/sdm845/linux/archive/sdm845-next-20260306-1.tar.gz";
      #url = "gitlab:sdm845-mainline/linux/sdm845-6.16.7-r0";
      #url = "https://codeberg.org/sdm845/linux/archive/1a28c2433756e6b0341284771ede7399a7206335.tar.gz";
      #url = "https://codeberg.org/sdm845/linux/archive/95a7b50116b18ecd2a286dffe6fb27462c87677a.tar.gz";
      # Broken
      # url = "https://codeberg.org/sdm845/linux/archive/bffa35abd8b429a5f73975f759db03e1cf51bfef.tar.gz";
      # Working
      #url = "https://codeberg.org/sdm845/linux/archive/4a7570c2dab02506fd091792454b978d8b03b0d1.tar.gz";
      #url = "gitlab:sdm845/sdm845-next/1a28c2433756e6b0341284771ede7399a7206335";
      #url = "gitlab:sdm845/sdm845-next/1a28c2433756e6b0341284771ede7399a7206335";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];
      imports = [
        ./oneplus-enchilada
        ./oneplus-fajita
      ];
    };
}

