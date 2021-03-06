# Wifi networks and things

{ config, ... }:

{
  networking = {
    hostName = "astatine";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ]; # See: https://github.com/NixOS/nixpkgs/issues/101963
      networks."Not Your Wifi".pskRaw =
        "248567fa391aaa867b6c61c99bd093e30f90be440d6b455fd0068645733fb919";
    };

    # Should be set to false from NixOS 19+
    useDHCP = false;

    interfaces = {
      enp1s0.useDHCP = false;
      wlp2s0.useDHCP = true;
    };

    firewall = {
      enable = true;
      allowedTCPPortRanges = [ { from = 1714; to = 1764; }]; # For kdeconnect
      allowedUDPPortRanges = [ { from = 1714; to = 1764; }]; # For kdeconnect
    };
  };
}
