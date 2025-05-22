localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;

  package = localFlake.packages.${pkgs.system}.pilum-murialis-xyz;

  cfg = config.services.pilum-murialis-xyz;
in
{
  options.services.pilum-murialis-xyz = {
    enable = mkEnableOption "pilum-murialis-xyz";
    package = mkPackageOption package "pilum-murialis-xyz" { };

    domain = mkOption {
      type = types.str;
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
