{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) str path;
in
{
  imports = [
    ./sops.nix
    ./nginx-module.nix
  ];
  options.services.website = {
    enable = mkEnableOption "Enable hosting the website";
    domain = mkOption {
      type = str;
      default = "example.com";
      description = "Domain to serve the website under";
    };
    homeDir = mkOption {
      type = path;
      default = "/var/lib/cloudflared";
      description = "Home directory for the cloudflared service";
    };
  };
}
