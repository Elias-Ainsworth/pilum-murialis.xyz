{
  config,
  pkgs,
  lib,
  domain ? "pilum-murialis.xyz",
  ...
}:

let
  sitePackage = pkgs.callPackage ../site { };
in
{
  options = {
    services.website.enable = lib.mkEnableOption "Enable hosting the website";
  };

  config = lib.mkIf config.services.website.enable {
    services.nginx = {
      enable = true;
      virtualHosts.${domain} = {
        root = "${sitePackage}/out";
        serverAliases = [
          domain
          "www.${domain}"
        ];
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
        ];
        locations."/" = {
          # extraConfig = "index index.html;";
          index = "index.html";
          tryFiles = "$uri $uri/ =404";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
