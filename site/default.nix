{ lib, runCommand }:

runCommand "my-site" { } ''
  cp -r ${./out} $out
''
