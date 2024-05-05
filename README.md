# Asahi Linux Gentoo Overlay

An overlay for Gentoo providing packages to better support Apple Silicon
devices.

## Installation
If you used [asahi-gentoosupport](https://github.com/chadmed/asahi-gentoosupport), you should not need to
do anything. That script sets up this repo automatically. For all other users:

1. Go clone asahi-gentoosupport
2. Copy `resources/package.mask` and `resources/package.use` to their homes in
   `/etc/portage/` (note: the `package.*` nodes in `/etc/portage/` should be folders)
3. Install `app-eselect/eselect-repository`
4. Run `eselect repository enable asahi`
5. Run `emaint sync -r asahi`

Enjoy!

If you intend to use a DE/WM with your system, please make sure to edit
`package.use` according to the instructions contained therein.

## Usage
No manual intervention is required to use this repo correctly as it
takes precedence over the Gentoo overlay. You can override this
behaviour and install a vanilla version of a package by appending
`::gentoo` to the package atom.

### Installing software
* To install our version of Mesa, you would run:
```shell
emerge -av mesa
```

* To use the default Gentoo ebuild for Mesa instead, you would run:
```shell
emerge -av media-libs/mesa::gentoo
```

### Updating software
In most cases, updating software involves nothing more than synchronising
the repo and updating the world set as you would on any other machine.

After updating m1n1, U-Boot or the kernel, it is important to run `update-m1n1`
as root to ensure that m1n1, U-Boot and the DTBs are installed to the ESP.
