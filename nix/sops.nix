{ config, ... }:
let
  cfg = config.services.website;
in
{
  sops = {
    # to edit secrets file, run "sops hosts/secrets.json"
    defaultSopsFile = ../secrets/cloudflare-cred.json;

    # use full path to persist as the secrets activation script runs at the start
    # of stage 2 boot before impermanence
    gnupg.sshKeyPaths = [ ];
    age = {
      sshKeyPaths = [ "/persist${cfg.homeDir}/.ssh/id_ed25519" ];
      keyFile = "/persist${cfg.homeDir}/.config/sops/age/keys.txt";
      # This will generate a new key if the key specified above does not exist
      generateKey = false;
    };
  };
}
