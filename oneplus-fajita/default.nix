{ inputs, ... }:
{
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      packages.x = pkgs.callPackage ./sdm845-uboot.nix { inherit inputs; };
      packages.sdm845-oneplus-fajita-uboot-bootimg =
        let
          uboot = pkgs.callPackage ./sdm845-uboot.nix { inherit inputs; };
        in
        pkgs.runCommand "sdm845-oneplus-fajita-uboot-bootimg"
          {
            nativeBuildInputs = with pkgs; [
              android-tools
            ];
          }
          ''
            cp ${uboot}/u-boot-nodtb.bin ./u-boot-nodtb.bin
            cp ${uboot}/sdm845-oneplus-fajita.dtb ./sdm845-oneplus-fajita.dtb
            gzip ./u-boot-nodtb.bin
            cat ./u-boot-nodtb.bin.gz ${uboot}/sdm845-oneplus-fajita.dtb > ubootwithdtb
            mkbootimg \
              --kernel ./ubootwithdtb \
              --base "0x00000000" \
              --kernel_offset "0x00008000" \
              --ramdisk_offset "0x01000000" \
              --second_offset "0x00000000" \
              --tags_offset "0x00000100" \
              --pagesize 4096 \
              -o $out
          '';
    };
  flake = {
    nixosConfigurations.sdm845-oneplus-fajita = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
#        "${inputs.nixpkgs}/nixos/modules/profiles/perlless.nix"
        ./sdm845.nix
        ./configuration.nix
        #        ./repart.nix
      ];
    };
  };
}
