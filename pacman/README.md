# The Pacman way

Pacman can be configured to install packages to our Arch ARM system. Just use
the supplied `pacman.conf`, mount the image and use the command:

    sudo pacman -r <mount-point> -Syu --config ./pacman.conf

This will use the `mirrorlist` found on the Arch ARM image. Further
documentation and options available in `pacman.conf`.
