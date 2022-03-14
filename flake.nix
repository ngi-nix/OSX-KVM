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

        fetchMacOS = pkgs.stdenv.mkDerivation {
          name = "fetchMacOS";
          buildInputs = [
            (pkgs.python38.withPackages (pyPkgs: with pyPkgs; [ requests click ]))
          ];
          unpackPhase = "true";
          installPhase = ''
            mkdir -p $out/bin
            cp ${osx-kvm}/tools/FetchMacOS/fetch-macos.py $out/bin/fetchMacOS
            chmod +x $out/bin/fetchMacOS
          '';
        };

        start =
          pkgs.writeShellScriptBin "start" ''
            set -e

            if [ ! -e disk0.qcow2 ];then
              ${self.packages.${system}.init}/bin/init
            fi

            cp ${osx-kvm}/firmware/OVMF_VARS-1024x768.fd OVMF_VARS.fd
            cp ${osx-kvm}/ESP.qcow2 .
            chmod a+w OVMF_VARS.fd
            chmod a+w ESP.qcow2

            export ramSize=$(jq -r '.ramSize' settings.json)
            export cores=$(jq -r '.cores' settings.json)
            export headless=$(jq -r '.headless' settings.json)

            if [ "$headless" == "true" ]; then
              headless="-nographic -vnc :0 -k en-us"
            else
              headless=""
            fi

            ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -enable-kvm \
              -m $ramSize \
              -machine q35,accel=kvm \
              -smp $(( $cores * 2 )),cores=$cores \
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
              $headless \
          '';

        init = pkgs.writeShellScriptBin "init" ''
          set -e
          if [ -e disk0.qcow2 ]; then
            echo "The current directory already contains disk0.qcow2. Delete it first!"
            exit 1
          fi

          # get settings from user input
          echo "choose disk size (example: 64G)" && echo -n "answer: "
          read diskSize
          echo "choose ram size (example: 6G)" && echo -n "answer: "
          read ramSize
          echo "choose number of cpu cores (example: 2)" && echo -n "answer: "
          read cores
          echo "choose MacOS version (example: 10.15) (leave empty for latest)" && echo -n "answer: "
          read osVersion

          jq=${pkgs.jq}/bin/jq
          sponge=${pkgs.moreutils}/bin/sponge
          echo "{}" > settings.json
          $jq ".ramSize = \"$ramSize\"" settings.json | $sponge settings.json
          $jq ".cores = \"$cores\"" settings.json | $sponge settings.json
          $jq ".headless = \"false\"" settings.json | $sponge settings.json

          if [ "$osVersion" == "" ]; then
            ${fetchMacOS}/bin/fetchMacOS
          else
            ${fetchMacOS}/bin/fetchMacOS -v $osVersion
          fi
          ${pkgs.dmg2img}/bin/dmg2img ./BaseSystem/BaseSystem.dmg ./BaseSystem.img
          rm -r ./BaseSystem

          ${pkgs.qemu}/bin/qemu-img create -f qcow2 disk0.qcow2 $diskSize
        '';

      in
      {
        packages = { inherit start init; };

        defaultPackage = start;
      });
}
