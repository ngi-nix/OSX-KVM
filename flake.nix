{
  description = "simple OSX KVM";

  inputs.nixpkgs.url = "nixpkgs/21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.osx-kvm.url = "github:foxlet/macOS-Simple-KVM";
  inputs.osx-kvm.flake = false;

  outputs = { self, nixpkgs, flake-utils, osx-kvm }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        fetchMacOS = pkgs.callPackage ./packages/fetchMacOS.nix { inherit osx-kvm; };

        init = pkgs.callPackage ./packages/init.nix { inherit fetchMacOS; };
        start = pkgs.callPackage ./packages/start.nix { inherit init osx-kvm; };
      in
      {
        packages = { inherit start init; };

        defaultPackage = start;
      });
}
