{ mkShell, pkgs, ... }:
mkShell {
  nativeBuildInputs = with pkgs; [
    curl
    statix
    nixfmt-rfc-style
  ];
}
