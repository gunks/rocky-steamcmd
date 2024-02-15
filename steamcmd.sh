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
readonly steamcmd_working_dir="/home/${local_user}/Steam"


###############
#  Functions  #
###############

create_user() {
  if id "${local_user}" 2>&1; then
    useradd --create-home --shell /bin/bash "${local_user}"
    cp /etc/skel/.bashrc /home/"${local_user}"/.bashrc
    cp /etc/skel/.profile /home/"${local_user}"/.profile
  fi
}

rocky_install_deps() {
  dnf install --assumeyes "${rocky_deps}"
}

rocky_upgrade() {
  dnf upgrade --assumeyes
}

steamcmd_download() {
  if [[ ! -d "${steamdcmd_working_dir}" ]]; then
    mkdir -p "${steamdcmd_working_dir}"
  fi
  wget --show-progress --directory-prefix "${steamcmd_working_dir}" "${steamcmd_url}"
}

steamcmd_install() {
  tar -xvzf
}

validate_working_dir() {
  return 0
}

##########
#  Main  #
##########

main() {
  rocky_upgrade
  create_user
  steamcmd_download



}

# main "$@"