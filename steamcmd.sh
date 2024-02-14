#!/usr/bin/env bash

# https://shape.host/resources/how-to-install-steamcmd-on-rocky-linux

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

########################
#  Configuration Vars  #
########################
readonly steam_id=""
readonly game_name=""
readonly server_name=""
readonly server_pass=""

#################
#  Expert Vars  #
#################
readonly local_user="steam"
readonly rocky_deps="tar wget unzip glibc.i686 libstdc++.i686"
readonly steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
readonly steamcmd_working_dir="/home/${local_user}"


###############
#  Functions  #
###############

create_user() {
  if
  # sudo useradd "${local_user}"
}

rocky_install_deps() {
  sudo dnf install --assumeyes "${rocky_deps}"
}

rocky_upgrade() {
  sudo dnf upgrade --assumeyes
}

steamcmd_download() {
  wget --show-progress --directory-prefix "${steamcmd_working_dir}" "${steamcmd_url}"
}


##########
#  Main  #
##########

main() {
  rocky_upgrade
  create_user

}

# main "$@"