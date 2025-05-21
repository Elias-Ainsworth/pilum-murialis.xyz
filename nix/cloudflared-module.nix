{ config, lib, ... }:

let
  cloudflaredCreds = builtins.fromJSON (builtins.readFile config.sops.secrets.cloudflared-creds.path);
  tunnelId = cloudflaredCreds.TunnelID;
in
{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "${tunnelId}" = {
        credentialsFile = config.sops.secrets.cloudflared-creds.path;
        ingress = {
          "pilum-murialis.xyz" = "http://localhost:80";
          "*.pilum-murialis.xyz" = "http://localhost:80";
        };
        default = "http_status:404";
      };
    };
  };

  sops.secrets.cloudflared-creds = {
    sopsFile = ./secrets/cloudflared-creds.json;
    owner = "cloudflared";
    group = "cloudflared";
  };
}
