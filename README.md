# OSX-KVM

A simple `flake.nix` to setup a macOS virtual machine based on https://github.com/foxlet/macOS-Simple-KVM

## Usage

If you want to go with the defaults, you don't need to clone this repo. But
it's generally recommended to, as you'll be running commands from here each
time you want to start the VM.

First, enter a devShell
```
nix develop
```

Then download one of the available macOS versions: High Sierra, Mojave or
Catalina
```
jumpstartCatalina
```

After downloading, set up the virtual disk. By default it's 64GB, but you can
edit the value in the flake
```
defaultDisk
```

Finally, start the VM
```
runMacOS
```

## Installing macOS

When booted into the VM, click on `Disk Utility`. Search for the disk with 64GB
(or your configured amount) and click `Erase`. Leave the options at their
default values, then click erase.

Once that's done, click exit and go to `Reinstall macOS`. The instructions
should be straightforward: click continue and agree, then select your disk.

## Additional options

You can change the amount of CPU cores or RAM the machine uses inside the flake.
