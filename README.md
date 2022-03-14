# OSX-KVM

A simple `flake.nix` to setup a macOS virtual machine based on https://github.com/foxlet/macOS-Simple-KVM

## Usage

```shell
mkdir macos
cd macos
nix run github:ngi-nix/OSX-KVM
```

## Headless mode

After the machine is set up, edit `./settings.json` and set `headless` to `true`.

## Installing macOS

When booted into the VM, click on `Disk Utility`. Search for the disk with 64GB
(or your configured amount) and click `Erase`. Leave the options at their
default values, then click erase.

Once that's done, click exit and go to `Reinstall macOS`. The instructions
should be straightforward: click continue and agree, then select your disk.

## Additional options

You can change the amount of CPU cores or RAM the machine uses by editing the `settings.json` generated after first launch.
