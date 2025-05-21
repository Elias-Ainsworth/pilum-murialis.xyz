{ stdenv ...}:
stdenv.mkDerivation {
  name = "pilum-murialis-xyz";
  src = ../src;
  installPhase = ''
    mkdir -p $out
    cp -r out/* $out/
  '';
}
