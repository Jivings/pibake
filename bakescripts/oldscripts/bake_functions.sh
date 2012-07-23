#!/bin/bash

ROOT='./archarm'
DB=$ROOT'/var/lib/pacman/local'
SYNC=$ROOT'/var/lib/pacman/sync'

LOCAL_SYNC='pacman/sync'
LOCAL_DB='pacman/local'
LOCAL_PKG='pacman/packages'

MIRROR='http://us.mirror.archlinuxarm.org/arm'

# validate resources are available
function init() 
{
  echo "Checking for required files"

  if [ ! -f pkglist ]
  then
    echo "No package list found. Did you forget to save 'pkglist'?";
    exit 1;
  fi
  if [ ! -f repos.conf ]
  then 
    echo "Cannot find repository listing: repos.conf";
    exit 1;
  fi
  if [ ! -d pacman ]
  then
    mkdir -p pacman/{sync,packages}
  fi
  
  if [ ! -d archarm ]
  then
    mkdir archarm
  fi

  echo "Download latest arch image? (y/n)"
  read download
  if [ "${download}" == "y" ];
  then
    echo "Not yet implemented"
  fi

  # mirror the image package database so we know when updates are needed
  mount_image "arch.img" "100999680"
  cp -R archarm/var/lib/pacman/local pacman/

  
  echo "Initialised local Arch repositories, please run with --sync";
}

# mount the image $1 at offset $2
function mount_image() 
{
  if [ "$(mount -o loop,offset=$2 $1 $ROOT)" == "1" ];
  then
    echo "Failed to mount. Perhaps the offset is incorrect?";
    exit 1;
  fi

  
}


# sync with arch arm repositories
function sync_local() 
{
  # retrieve all the package databases
  wget -q -P pacman/sync -i repos.conf
  # extract the package info
  mkdir -p pacman/sync/{core,extra,community,aur,alarm}
  tar -xzf pacman/sync/core.db.tar.gz       -C  pacman/sync/core
  tar -xzf pacman/sync/extra.db.tar.gz      -C  pacman/sync/extra
  tar -xzf pacman/sync/community.db.tar.gz  -C  pacman/sync/community
  tar -xzf pacman/sync/aur.db.tar.gz        -C  pacman/sync/aur
  tar -xzf pacman/sync/alarm.db.tar.gz      -C  pacman/sync/alarm
  
  # check for updated versions of our selected/installed packages
  while read line
  do
    # get sync properties
    local PKG=$(echo $(echo "$line") | awk '{print $2}');
    local REPO=$(echo $(echo "$line") | awk '{print $1}');
    local DESC=$(cat ${LOCAL_SYNC}/${REPO}/${PKG}*/desc);
    local VERSION=$( echo $(echo "$DESC" | grep -A 1 "%VERSION%") | awk '{print $2}' );
    local ARCH=$( echo $(echo "$DESC" | grep -A 1 "%ARCH%") | awk '{print $2}' );
    
    # get local file properties
    local L_DESC=$( cat ${LOCAL_DB}/${PKG}*/desc);
    local L_VERSION=$( echo $(echo "$L_DESC" | grep -A 1 "%VERSION%") | awk '{print $2}' );

    # check if repo version is newer than local version
    if [ "${L_VERSION}" != "${VERSION}" ];
    then
      # update available
      local URL=$( echo $(echo "$DESC" | grep -A 1 "%FILENAME%") | awk '{print $2}' );
      # delete old package
      NAME=$(echo "$DESC" | grep -A 1 "%NAME%");
      FILENAME=$(echo ${NAME} | awk '{print $2}')
      if [ -f ${LOCAL_PKG}/${FILENAME}* ];
      then
        rm -R ${LOCAL_PKG}/${FILENAME}*
      fi
      # download new one
      echo "Downloading ${URL}"
      wget -q ${MIRROR}/${REPO}/${URL} -P pacman/packages/
      if [ $? != "0" ];
      then
        echo "Something went wrong"
        exit 1;
      fi;
      
      # update local database
      N_VERSION=$(echo "$DESC" | grep -A 1 "%VERSION%");
      URL=$(echo "$DESC" | grep -A 1 "%URL%");
      BUILDDATE=$(echo "$DESC" | grep -A 1 "%BUILDDATE%");
      INSTALLDATE="%INSTALLDATE%\n"$(date +%s);
      PACKAGER=$(echo "$DESC" | grep -A 1 "%PACKAGER%");
      REASON="%REASON%\n0"
      SIZE="%SIZE%\n"$(echo $(echo "$DESC" | grep -A 1 "%ISIZE%") | awk '{print $2}')
      # remove old entry
      rm -R ${LOCAL_DB}/${FILENAME}*
      # create the entry 
      mkdir ${LOCAL_DB}/${PKG}
      echo -e "$NAME""\n\n""$N_VERSION""\n\n""$URL""\n\n""$BUILDDATE""\n\n""$INSTALLDATE""\n\n""$PACKAGER""\n\n""$REASON""\n\n""$SIZE" > ${LOCAL_DB}/${PKG}/desc
      echo "$FILENAME ${PKG}-${VERSION}-${ARCH}.pkg.tar.xz" >> imageupdates
    
    fi
  done < pkglist
}

function upgrade_image
{
  # If sync sees that base packages need upgrading it will create the file
  # imageupdates. This will install base packages that are in that file.
  #
  while read line
  do
    PKG=$(echo "$line" | awk '{print $2}');
    UPDATE_EXISTS=$(grep "^${PKG} " imageupdates);
    if [ ! -z "${UPDATE_EXISTS}" ];
    then
      FILE=$(echo "$UPDATE_EXISTS" | awk '{print $2}');
      echo "Installing ${FILE}..."
      tar -Jxf pacman/packages/$FILE -C archarm
      if [ $? != "0" ];
      then
        exit 1
      fi
    fi
  done < basepkgs
  #rm imageupdates
}


# sync local repositories with arch image
function sync_image() 
{
  cp -R ${LOCAL_SYNC}/* ${SYNC}
}

function search_local() 
{
  # TODO
  echo "Local search not yet implemented."; exit 1;
}


function install_packages() 
{
  while read line
  do
    PKG="$line"
    # insert db entry
    cp -R ${LOCAL_DB}/${PKG} ${DB}/${PKG}
    # extract package
    tar -Jxf "pacman/packages/${PKG}"   -C archarm/
    
  done < userpkgs
}

function cleanup {
  umount archarm
}
