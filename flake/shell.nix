{ mkShell, pkgs, ... }:
mkShell {
  nativeBuildInputs = with pkgs; [
    # Just in case
    curl
    git
    emacs

    # Nix tools
    deadnix
    nixfmt-rfc-style
    pre-commit
    statix

    # LSPs
    nixd
  ];
}
