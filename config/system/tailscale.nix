{
  pkgs,
  lib,
  hostConfig,
  ...
}:

lib.mkIf hostConfig.tailscale {
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
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 5 && ${pkgs.tailscale}/bin/tailscale down && sleep 5 && ${pkgs.tailscale}/bin/tailscale up'";
    };
  };
}
