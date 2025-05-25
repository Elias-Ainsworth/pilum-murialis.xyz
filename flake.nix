{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        { pkgs, ... }:
        {
          packages = {
            deploy-blog = pkgs.writeShellApplication {
              name = "deploy-blog";
              runtimeInputs = [ pkgs.systemd ];
              text = # bash
                ''
                  echo "Manually deploying blog..."
                  systemctl start blog-rebuild
                  echo "Check status with: systemctl status blog-rebuild"
                '';
            };
          };

          devShells = rec {
            default = development;
            development = pkgs.callPackage ./flake/shell.nix { };
          };
        };
      flake = {
        nixosModules = rec {
          default = pilum-murialis-xyz;
          pilum-murialis-xyz = import ./flake/nixos.nix self;
        };
      };
    };
}
