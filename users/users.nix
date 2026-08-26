{
  pkgs,
  config,
  username,
  host,
  hostConfig,
  ...
}:
{
  users.users = {
    "${username}" = {
      homeMode = "755";
      hashedPassword = "$6$YdPBODxytqUWXCYL$AHW1U9C6Qqkf6PZJI54jxFcPVm2sm/XWq3Z1qa94PFYz0FF.za9gl5WZL/z/g4nFLQ94SSEzMg5GMzMjJ6Vd7.";
      isNormalUser = true;
      description = hostConfig.gitUsername;
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "input"
        "cdrom"
        "ydotool"
      ];
      shell = pkgs.${hostConfig.theShell};
      ignoreShellProgramCheck = true;
      packages = with pkgs; [ ];
    };
    # "newuser" = {
    #   homeMode = "755";
    #   You can get this by running - mkpasswd -m sha-512 <password>
    #   hashedPassword = "$6$YdPBODxytqUWXCYL$AHW1U9C6Qqkf6PZJI54jxFcPVm2sm/XWq3Z1qa94PFYz0FF.za9gl5WZL/z/g4nFLQ94SSEzMg5GMzMjJ6Vd7.";
    #   isNormalUser = true;
    #   description = "New user account";
    #   extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    #   shell = pkgs.${theShell};
    #   ignoreShellProgramCheck = true;
    #   packages = with pkgs; [];
    # };
  };
}
