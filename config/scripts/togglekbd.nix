{ pkgs, host, ... }:

let
  inherit ( import ../../hosts/${host}/options.nix ) terminal browser;
in
pkgs.writeShellScriptBin "togglekbd" ''
   kitty
''
