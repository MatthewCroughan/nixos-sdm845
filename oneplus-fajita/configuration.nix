{
  imports = [
    ./repart.nix
    ./wireless.nix
  ];
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };
  users.users.root.password = "default";
}
