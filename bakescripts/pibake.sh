#!/bin/bash

PIBAKE_DIR=$(dirname $0);

function init() 
{
  echo -ne "Checking git..........";
  command -v git >/dev/null && echo "[yes]" || 
  { 
    echo "[no]";
    echo "pibake requires git"
    exit 1;
  } 
  sleep 1

  echo -ne "Checking parted.......";
  command -v parted >/dev/null && echo "[yes]" || 
  { 
    echo "[no]";
    echo "pibake requires parted."
    exit 1;
  } 
  sleep 1

  echo -ne "Checking piing........";
  # install piimg 
  command -v piimg >/dev/null && echo "[yes]" || 
  { 
    echo "[no]"; 
    echo "Installing piimg";
    git clone git://github.com/alexchamberlain/piimg.git
    cd piimg
    make
    sudo make install
    cd ..
    rm -rf piimg
    echo "[done]";
  }
  sleep 1

  echo -ne "Checking pacman......";
  command -v pacman >/dev/null && echo "[yes]" ||
    {
      echo "[no]";
      echo "pacman required for updating and installing Arch images";
      exit 1;
    }
  sleep 1

  echo -ne "Creating directories....."  
  if [ ! -d images ];
  then
    echo -ne "\n./images/arch"
    mkdir -p ./images/arch;
  fi
  if [ ! -d pimount ];
  then
    echo -ne "\n./pimount"
    mkdir ./pimount
  fi
  if [ ! -d pacman ];
  then 
    echo -ne "\n./pacman"
    mkdir -p ./pacman/cache/
  fi  
  echo -ne "\n[done]\n";
  
  sleep 1
  echo -ne "Downloading latest Arch image...";
  wget "http://files.velocix.com/c1410/images/archlinuxarm/archlinuxarm-13-06-2012/archlinuxarm-13-06-2012.zip" -O ./images/arch/archarm-latest.zip 
  echo "[done]";
  echo "Extracting image...";
  unzip ./images/arch/archarm-latest.zip 
  echo "[done]"
  echo -ne "Verifying image...."
  cd archlinux*
  sha1sum -c *.sha1 --status && echo "[ok]" || 
    {
      echo "Checksum failed. Invalid image. Retry downloading.";
      exit 1;
    }

  

  mv *.img ../images/arch/latest.img
  cd .. && rm -R archlinux*
  echo "Finished. You should now upgrade the image with --sync";
}

PIBAKE_TMP="/dev/shm/pibake";

function sync() 
{
  echo "Syncing image with repositories...";
  mkdir pimount 
  mount_pi "pimount"

  sleep 2
  pacman -r pimount -Syu --config ${PIBAKE_DIR}/pacman.conf

  sleep 2
  umount pimount/var/cache/pacman
  umount pimount/dev/pts
  umount pimount/dev/shm
  umount pimount/dev/loop1
  umount pimount/dev/loop3
  umount pimount/dev
  umount pimount/proc
  umount pimount/sys
  umount pimount/boot
  umount pimount
  
  rmdir pimount
  #cp ${PIBAKE_DIR}/images/arch/latest.img ${PIBAKE_TMP}
}

function mount_pi()
{
  echo "Mounting image..."
  piimg mount ${PIBAKE_DIR}/images/arch/latest.img $1
  mount pacman/cache pimount/var/cache/pacman
  cp /usr/local/bin/qemu-arm $1/usr/local/bin
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
      echo "This will upgrade the image at ${PIBAKE_DIR}/images/arch/latest.img to the latest package versions";
      echo "Are you sure this is what you want? (y/n)";
      read y
      if [ ! "$y" == "y" ]
      then 
        exit 0;
      fi
      sync
      ;;
    "--clean")
      rm -R pacman
      rm -R images
      ;;
    "--init")
      init
    ;;
    "--debug")
      upgrade_image
  esac
done



