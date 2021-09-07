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

      runMacOS =
        let
          inherit (nixpkgs.lib) optionalString;
          cores = 2;
          ram = "6G";
          headless = false;
        in
        final.writeShellScriptBin "runMacOS" ''
          cp ${osx-kvm}/firmware/OVMF_VARS-1024x768.fd OVMF_VARS.fd
          cp ${osx-kvm}/ESP.qcow2 .
          chmod a+w OVMF_VARS.fd
          chmod a+w ESP.qcow2

          ${final.qemu}/bin/qemu-system-x86_64 \
             -enable-kvm \
             -m ${ram} \
             -machine q35,accel=kvm \
             -smp ${toString (cores * 2)},cores=${toString cores} \
             -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
             -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
             -smbios type=2 \
             -drive if=pflash,format=raw,readonly=on,file="${osx-kvm}/firmware/OVMF_CODE.fd" \
             -drive if=pflash,format=raw,file="OVMF_VARS.fd" \
             -vga qxl \
             -device ich9-intel-hda -device hda-output \
             -usb -device usb-kbd -device usb-mouse \
             -netdev user,id=net0 \
             -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
             -device ich9-ahci,id=sata \
             -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
             -device ide-hd,bus=sata.2,drive=ESP \
             -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img \
             -device ide-hd,bus=sata.3,drive=InstallMedia \
             -drive id=SystemDisk,if=none,file=disk0.qcow2 \
             -device virtio-blk,drive=SystemDisk \
             ${optionalString headless "-nographic -vnc :0 -k en-us"} \
        '';
    };

  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    {
      packages = { inherit (pkgs) fetchMacOS runMacOS; };

      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          qemu-utils
          dmg2img
          fetchMacOS
          runMacOS
        ];

        shellHook =
          let
            scriptFor = version: ''
              fetchMacOS -v ${version} && dmg2img ./BaseSystem/BaseSystem.dmg ./BaseSystem.img
            '';
          in
          ''
            alias jumpstartHighSierra="${scriptFor "10.13"}"
            alias jumpstartMojave="${scriptFor "10.14"}"
            alias jumpstartCatalina="${scriptFor "10.15"}"

            alias defaultDisk="qemu-img create -f qcow2 disk0.qcow2 64G"
          '';
      };
    });
}
