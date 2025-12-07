{ lib, ... }:
{
  boot.initrd.kernelModules = lib.mkAfter [
    # Testing
    "dispcc-sdm845"
    "gpucc-sdm845"
  ];

}
