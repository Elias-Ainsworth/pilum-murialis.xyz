{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    { flake-parts, systems, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, self, ... }:
      {
        systems = import systems;

        flake = {
          nixosModules = rec {
            # default = config.nixosModules.pilum-murialis-xyz;
            default = pilum-murialis-xyz;
            pilum-murialis-xyz = import ./flake/nixos.nix self;
          };
        };

        perSystem =
          { config, pkgs, ... }:
          {
            packages = {
              default = config.packages.pilum-murialis-xyz;
              pilum-murialis-xyz = pkgs.callPackage ./flake/package.nix { };
            };

            devShells = {
              default = config.devShells.development;
              development = pkgs.callPackage ./flake/shell.nix { };
            };
          };
      }
    );
}
