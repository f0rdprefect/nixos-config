{ pkgs, username, wallpaperDir, wallpaperGit }:

pkgs.writeShellScriptBin "wallgetter" ''
    ${pkgs.gitFull}/bin/git clone ${wallpaperGit} ${wallpaperDir}
    chown -R ${username}:users ${wallpaperDir}
''
