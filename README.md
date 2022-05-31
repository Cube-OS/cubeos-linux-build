# Cube-OS Linux

## Overview

Check out the official [Kubos Linux](https://docs.kubos.com/latest/ecosystem/index.html#kubos-linux) documentation for the most current instructions on how to setup and interact with Cube-OS Linux on specific boards. 
Cube-OS uses BuildRoot as its main Linux build tool.  This repo contains the configuration and patch files required by BuildRoot to build Linux for each of the OBCs that Cube-OS supports.

## Contributing

Want to get your code to space? Become a contributor! Check out our doc on [contributing to KubOS](https://docs.kubos.com/latest/contributing/contribution-process.html) 
and come talk to us on [Slack](https://slack.kubos.co/) to join our community. 
Or, if you're just looking to give some feedback, 
submit an [issue](https://github.com/kubos/kubos-linux-build/issues) with your feature requests or bug reports! 

## Files and folders

### external.desc

This file contains the name and description for the cubeos-linux-build folder.  BuildRoot will use it to create a link between the 
main BuildRoot folder and the cubeos-linux-build folder.

### external.mk

Currently (intentionally) empty.  This file is required by BuildRoot when creating the external link to the cubeos-linux-build folder,
but no content is actually required.

### Config.in

Currently empty.  Same as the external.mk file, BuildRoot requires that this file exist, but not that it have any content.

### board/cubeos/{board}

Inside of each of these folders are the patches and configuration files for each of the components required to build Linux for
a particular board.

### configs

This folder contains the BuildRoot configuration files needed to build each OBC supported by Cube-OS.

## Installation

In order to build Cube-OS Linux, two components are needed:

- The [cubeos-linux-build repo](https://github.com/Cube-OS/cubeos-linux-build) - Contains the configurations, patches, and extra tools needed to build Cube-OS Linux
- [BuildRoot](https://buildroot.org/) - The actual build system

These components should be setup as children of the same parent directory. 
There are several commands and variables in the build process which use relative file paths to navigate between the components.

After the environment has been set up, all build commands will be run from the BuildRoot directory unless otherwise stated.

To set up a build environment and build Cube-OS Linux:

Create a new parent folder to contain the build environment

    $ mkdir cubeos-linux

Enter the new folder

    $ cd cubeos-linux
  
Download BuildRoot-2019.02.2 (more current versions of BuildRoot may work as well,
but all testing has been done against 2019.02.2)

.. note:: All Cube-OS documentation will refer to v2019.02.2, which is the latest version of the LTS release at the time of this writing.

    $ wget https://buildroot.uclibc.org/downloads/buildroot-2019.02.2.tar.gz && tar xvzf buildroot-2019.02.2.tar.gz && rm buildroot-2019.02.2.tar.gz
  
Pull the cubeos-linux-build repo

    $ git clone http://github.com/Cube-OS/cubeos-linux-build
  
Move into the buildroot directory

    $ cd buildroot-2019.02.2
  
Point BuildRoot to the external cubeos-linux-build folder and tell it which configuration you want to run (config files are located in
cubeos-linux-build/configs)

    $ make BR2_EXTERNAL=../cubeos-linux-build {board}_defconfig
  
Build everything

    $ sudo make
  
The full build process will take a while.  Running on a Linux VM, it took about an hour.  Running in native Linux, it took about
twenty minutes.  Once this build process has completed once, you can run other BuildRoot commands to rebuild only certain sections
and it will go much more quickly (<5 min).

> Note: If you're using Vagrant, as with the Cube-OS SDK, do not use a shared folder for the cubeos-linux-build or buildroot directories, as the build process uses hardlinks that error with vagrant's shared folders.  

BuildRoot documentation can be found [**here**](https://buildroot.org/docs.html)

The generated files will be located in buildroot-2019.02.2/output/images.  They are:

- uboot.bin   - The U-Boot binary
- kernel      - The compressed Linux kernel file
- {board}.dtb - The Device Tree Binary that Linux uses to configure itself for your board
- rootfs.tar  - The root file system.  Contains BusyBox and other libraries

These files may be further packaged into various system images.
Specific details are listed in the appropriate [Building Linux for {OBC}](https://docs.kubos.com/latest/deep-dive/index.html#kubos-linux)
doc.

