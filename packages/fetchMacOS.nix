{ stdenv, python38, osx-kvm }:

stdenv.mkDerivation {
  name = "fetchMacOS";

  buildInputs = [
    (python38.withPackages (pyPkgs: with pyPkgs; [ requests click ]))
  ];

  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${osx-kvm}/tools/FetchMacOS/fetch-macos.py $out/bin/fetchMacOS
    chmod +x $out/bin/fetchMacOS
  '';
}
