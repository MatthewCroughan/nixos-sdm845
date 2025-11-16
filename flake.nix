{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    linux = {
      url = "gitlab:sdm845-mainline/linux/sdm845/6.16-dev";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];
      imports = [
        ./oneplus-enchilada
      ];
    };
}

