{ ... }:
{
  imports = [ ../../modules/virtusb.nix ];
  modules.virtusb = {
    enable = true;
    username = "matt";
    extraPackages = true;
  };
}
