{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.website;
  sitePackage = pkgs.callPackage ../site { };
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        root = "${sitePackage}";
        serverAliases = [
          cfg.domain
          "www.${cfg.domain}"
        ];
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
        ];
        locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri/ =404";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
