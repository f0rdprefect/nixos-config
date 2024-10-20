{ config, lib, host, ... }:

let inherit (import ../../hosts/${host}/options.nix) tailscale; in
lib.mkIf (tailscale == true) {
  services = {
    tailscale.enable = true;
  };
}
