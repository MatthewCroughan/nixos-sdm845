{
  imports = [
    ./repart.nix
    ./wireless.nix
    ./bullshit.nix
  ];
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };
  users.users.root.password = "default";
}
