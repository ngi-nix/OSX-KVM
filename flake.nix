{
  description = "simple OSX KVM";

  inputs.nixpkgs.url = "nixpkgs/21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.osx-kvm.url = "github:foxlet/macOS-Simple-KVM";
  inputs.osx-kvm.flake = false;
}
