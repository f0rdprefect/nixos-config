{ config, sops, ... }:
{
  # This is the actual specification of the secrets.
  sops.secrets.borg-base-rustic-repo = { };
  sops.secrets.rustic-xin = { };
  sops.templates."rustic.toml" = {
    content = ''

      # rustic config file to backup /home/matt and /etc to borgbase repository

      [repository]
      repository ="${config.sops.placeholder.borg-base-rustic-repo}"
      password = "${config.sops.placeholder.rustic-xin}"
      no-cache = false

      # Global hooks: The given commands are called for every command
      [global.hooks]
      run-before = [
       # long form giving command and args explicitly and allow to specify failure behavior
       { command = "echo", args = ["before"], on-failure = "warn" }, # allowed values for on-failure: "error" (default), "warn", "ignore"
      ] # Default: []
      run-after = ["echo after"] # Run after if successful, short version, default: []
      run-failed = ["echo failed"] # Default: []
      run-finally = ["echo finally"] # Always run after, default: []

      [forget]
      keep-daily = 14
      keep-weekly = 5

      [backup]
      exclude-if-present = [".nobackup", "CACHEDIR.TAG", ".git"]
      custom-ignorefiles = [".rusticignore", ".backupignore"] # Default: not set

      [[backup.snapshots]]
      label = "matts home"
      sources = ["/home/matt/"]

      git-ignore = true
    '';
    path = "/home/matt/.config/rustic/rustic.toml";
    owner = "matt";
  };
}
