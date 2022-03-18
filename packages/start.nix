{ stdenvNoCC
, init
, jq
, lib
, makeWrapper
, osx-kvm
, qemu
}:

stdenvNoCC.mkDerivation {
  name = "start";
  src = ./start.sh;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/start
    chmod a+x $out/bin/start
    wrapProgram $out/bin/start \
      --prefix PATH : ${lib.makeBinPath [ init jq qemu ]} \
      --set OSX ${osx-kvm}
  '';
}
