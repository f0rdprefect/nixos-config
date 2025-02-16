{
  home.file.".config/rustic/rustic.toml".text = ''

    # rustic config file to backup /home and /etc to a local repository

    [repository]
    repository = "rest:https://s2qe9430:fGUokGX5x6e7CA2F@s2qe9430.repo.borgbase.com"
    password-file = "/home/matt/.config/rustic/password.txt"
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
}
