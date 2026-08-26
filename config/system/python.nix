{
  pkgs,
  lib,
  hostConfig,
  ...
}:

let
  my-python-packages =
    ps: with ps; [
      pandas
      requests
    ];
in
lib.mkIf hostConfig.python {
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages my-python-packages)
  ];

}
