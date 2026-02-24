{
  pkgs,
  lib,
  config,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../hosts/${host}/options.nix) tailscale;
in
lib.mkIf (tailscale == true) {
  services = {
    tailscale.enable = true;
  };
  systemd.services.tailscale-resume = {
    description = "Restart Tailscale after resume from suspend";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 3 && ${pkgs.tailscale}/bin/tailscale down && sleep 3 && ${pkgs.tailscale}/bin/tailscale up'";
    };
  };
}
