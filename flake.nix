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
          # packages = rec {
          #   pilum-murialis-xyz = pkgs.callPackage ./flake/package.nix { };
          #   default = pilum-murialis-xyz;
          # };

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
