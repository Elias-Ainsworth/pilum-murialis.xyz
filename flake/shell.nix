{
  inputs,
  mkShell,
  pkgs,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    # Just in case
    curl
    git
    inputs.thornemacs.packages.${system}.default
    # Nix tools
    deadnix
    nixfmt-rfc-style
    pre-commit
    statix

    # LSPs
    nixd
  ];
}
