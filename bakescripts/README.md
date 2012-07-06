# PiBakery Bash Scripts

These scripts are the oven of the Pi Bakery.

## PiBake.sh

Responsible for initialisation of the bakery environment for the baking of new Pi
images, PiBake.sh can be executed with one of three different parameters:

    ./pibake.sh --init

This will download and mount the Pi image. The application repository on the
image will be copied to the local system and appropriate directories created.

    ./pibake.sh --sync

Using the local repositories from the image, pibake will synchronise the system
with the remote, up to date repositories. 

In this stage all packages listed in `pkglist` that do not exist locally will be 
downloaded. Any packages that do exist and our out of date will be upgraded.
These packages will then be migrated onto the Pi image where appropriate in
order to keep a bleeding edge image.

    ./pibake.sh --bake

All packages in `userpkgs` will be installed to the image. These should have
been downloaded in the `--sync` operation. This creates the custom,
user-defined Pi image.

## basepkgs

This file contains a list of the packages that are installed by default on a
base system. Included are package name and repository. This is used when
updating the basic Pi image. 

Unless it is found to be incomplete, **this file should not be edited**.

## pkglist

This file represents all of the packages the Pi Bakery allow to be selected as
ingredients, as well as all of the `basepgks`. This is used for synchronising
the local repository with the official repositories. 

If this file is changed, `pibake.sh --sync` must be executed so that the
new packages are downloaded and can be installed.

### Issues

 - `--bake` command is not completely tested.
 - `--sync` yields errors. Exit conditions exist so that it can be debugged.
   Some downloads fail, which produces installation errors.

