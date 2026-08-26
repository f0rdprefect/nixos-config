{
  pkgs,
  flakeDir,
  host,
  ...
}:

pkgs.writeShellScriptBin "themechange" ''
  if [[ ! $@ ]]; then
    echo "No Theme Given"
    exit 1
  else
    echo "themechange no longer edits hosts/*/options.nix."
    echo "Set hostProfiles.${host}.theme in flake.nix manually, then rebuild."
    exit 1
  fi
''
