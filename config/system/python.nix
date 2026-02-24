{
  pkgs,
  config,
  lib,
  ...
}:

let
  host = config.networking.hostName;
  inherit (import ../../hosts/${host}/options.nix) python;
  my-python-packages =
    ps: with ps; [
      pandas
      requests
    ];
in
lib.mkIf (python == true) {
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages my-python-packages)
  ];

}
