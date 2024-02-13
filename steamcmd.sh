#!/usr/bin/env bash

# https://shape.host/resources/how-to-install-steamcmd-on-rocky-linux

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

########################
#  Configuration Vars  #
########################


#################
#  Expert Vars  #
#################
readonly steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
readonly rocky_deps="tar wget unzip glibc.i686 libstdc++.i686"

###############
#  Functions  #
###############

download_steamcmd() {
  wget --show-progress --directory-prefix 
}

rocky_install_deps() {
  sudo dnf install "${rocky_deps}"
}

rocky_update() {
  return 0
}

