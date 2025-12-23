{ pkgs, lib, inputs, config, ... }:

let
  n1 = (pkgs.writeText "DoESLiverpool.psk" ''
    [Security]
    Passphrase=decafbad00
  '');
  n2 = (pkgs.writeText "gast-ost.psk" ''
    [Security]
    Passphrase=6isgpu9e
  '');
  n3 = (pkgs.writeText "DoESLiverpool-5g.psk" ''
    [Security]
    Passphrase=decafbad00
  '');
in
{
  config = {
    networking.wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
      settings.General.AddressRandomization = "once";
    };
    systemd.tmpfiles.rules = [
      "C /var/lib/iwd/DoESLiverpool.psk 0600 root root - ${n1}"
      "C /var/lib/iwd/gast-ost.psk 0600 root root - ${n2}"
      "C /var/lib/iwd/DoESLiverpool-5g.psk 0600 root root - ${n3}"
    ];
  };
}
