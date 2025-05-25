{
  mkShell,
  pkgs,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    # Just in case
    curl
    git

    # Nix tools
    deadnix
    nixfmt-rfc-style
    pre-commit
    statix

    # LSPs
    nixd
  ];
}
