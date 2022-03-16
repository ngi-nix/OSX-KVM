{ stdenv
, dmg2img
, fetchMacOS
, jq
, lib
, makeWrapper
, moreutils
, qemu
}:

stdenv.mkDerivation {
  name = "init";
  src = ./init.sh;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/init
    chmod a+x $out/bin/init
    wrapProgram $out/bin/init \
      --prefix PATH : ${lib.makeBinPath [ jq moreutils fetchMacOS dmg2img qemu ]}
  '';
}
