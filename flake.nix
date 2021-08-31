{
  description = "simple OSX KVM";

  inputs.nixpkgs.url = "nixpkgs/21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.osx-kvm.url = "github:foxlet/macOS-Simple-KVM";
  inputs.osx-kvm.flake = false;

  outputs = { self, nixpkgs, flake-utils, osx-kvm }: {

    overlay = final: prev: {
      fetchMacOS = final.stdenv.mkDerivation {
        name = "fetchMacOS";
        buildInputs = [
          (final.python38.withPackages (pyPkgs: with pyPkgs; [ requests click ]))
        ];
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp ${osx-kvm}/tools/FetchMacOS/fetch-macos.py $out/bin/fetchMacOS
          chmod +x $out/bin/fetchMacOS
        '';
      };
    };

  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    {
      packages = { inherit (pkgs) fetchMacOS; };
    });
}
