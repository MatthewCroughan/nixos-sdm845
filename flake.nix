{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    linux = {
      url = "gitlab:sdm845/sdm845-next";
      #url = "gitlab:sdm845-mainline/linux/sdm845-6.16.7-r0";
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

