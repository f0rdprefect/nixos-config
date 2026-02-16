{ sops, config, ... }:
let
  host = config.networking.hostName;
in
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "${host}/newt/id" = { };
      "${host}/newt/secret" = { };
      "${host}/newt/endpoint" = { };
    };
  };
  sops.templates."newt.env" = {
    content = ''
      NEWT_ID="${config.sops.placeholder."${host}/newt/id"}"
      NEWT_SECRET="${config.sops.placeholder."${host}/newt/secret"}"
      PANGOLIN_ENDPOINT="${config.sops.placeholder."${host}/newt/endpoint"}"
    '';
    owner = "root";
    # mode = "0400";
  };
  services.newt = {
    enable = true;
    environmentFile = config.sops.templates."newt.env".path;
  };
}
