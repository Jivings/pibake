#!/bin/bash
. $(dirname $0)/bake_functions.sh

function sync
{
  echo "Syncing local repositories"
  sync_local
  mount_image "arch.img" "100999680"
  echo "Syncing image repositories"
  sync_image

  echo "Upgrading image"
  upgrade_image
# echo "Extracting packages"
#  install_packages
  echo "Update complete"

  cleanup
}

function bake
{
  echo "Baking custom image"
  mount_image "arch.img" "100999680"
  echo "Downloading user packages"
  download_packages
  echo "Installing user packages"
  install_packages
  echo "Baking complete."
  cleanup
}


if [ "$(id -u)" != "0" ];
then
  echo "This script must be run as root";
  exit 1;
fi


for arg in "$@"
do
  case "$arg" in

    "--sync")
      sync
      ;;
    "--bake")
      bake
      ;;
    "--init")
      init
      cleanup
    ;;
    "--debug")
      upgrade_image
  esac
done



