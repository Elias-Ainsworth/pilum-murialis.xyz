{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      systems,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      perSystem =
        { system, pkgs, ... }:
        {
          packages.default = pkgs.stdenv.mkDerivation {
            name = "website";
            src = ./site;
            installPhase = ''
              mkdir -p $out
              cp -r out/* $out/
            '';
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              curl
              sops
              statix
              nixfmt-rfc-style
            ];
          };
        };

      flake.nixosModules.default = {
        imports = [ ./nix/default.nix ];
      };
    };
}
