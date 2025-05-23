self:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.types) str package;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;

  # package = localFlake.packages.${pkgs.system}.pilum-murialis-xyz;
  packages = self.packages.${pkgs.system};

  cfg = config.services.pilum-murialis-xyz;
in
{
  options.services.pilum-murialis-xyz = {
    enable = mkEnableOption "pilum-murialis-xyz";
    package = mkOption {
      type = package;
      inherit (packages) default;
    };
    domain = mkOption {
      type = str;
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        root = "${cfg.package}";
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
