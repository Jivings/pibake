## PiBakery Bash Scripts

These scripts are the oven of the Pi Bakery.

# PiBake.sh

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
