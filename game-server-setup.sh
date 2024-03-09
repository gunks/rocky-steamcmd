#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"

#########################
#  Steam Configuration  #
#########################

readonly steam_username="steam"
readonly steamcmd_dir="/home/${steam_username}/SteamCmd"

readonly game_name=""
readonly game_steam_id=""
readonly game_dir="/home/${steam_username}/${game_name:-steamApp}"


##########################
#  Server Configuration  #
##########################

server_name=""
server_pass=""
server_port=""
server_save_name=""
server_extra_args=""

#################
#  Expert Vars  #
#################

readonly steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
readonly rocky_deps="tar wget unzip glibc.i686 libstdc++.i686"
readonly required_bins=("readlink")


###################
#  Parse Options  #
###################



################
#  Usage/Help  #
################

usage() {
  printf "\n\nUsage: ${0} [OPTIONS]\n"
  printf "Options:\n"
  printf "  -h. --help    Display this help message.\n\n"
}


################
#  Pre-Flight  #
################

# A sequence of functions used to test if this script has everything it needs to run
preflight() {
  validate_bins
  validate_steam_id
}

# Test if all bash commands from a global array are valid/installed
validate_bins() {
  if [[ -n ${required_bins:+1} ]]; then
    return 0
  fi

  local exit_flag=false
  for bin in "${required_bins[@]}"; do
    if ! command -v "${bin}" &> /dev/null; then
      printf 'ERROR: %s is not installed!\n' "${bin}"
      exit_flag=true
    fi
  done

  if ${exit_flag}; then
    exit 1
  else
    return 0
  fi
}

validate_steam_id() {
  local exit_flag=false

  if [[ -z ${game_steam_id} ]]; then
    print_err "No steam ID has been given!"
    exit 1
  else
    return 0
  fi
}


###############
#  Functions  #
###############

# Adds the user executing this script to the steamuser Group.
add_self_to_steamgroup() {
  local myname="$(whoami)"

  sudo usermod -a -G "${steam_username}" "${myname}"
}

# Create a non-root user for running the steamcmd server
create_steamuser() {
  if id -u "${steam_username}" >/dev/null 2>&1; then
    sudo useradd --create-home --shell /bin/bash "${steam_username}"
  else
    return 0
  fi
}

# Create a Directory named $1 as user $2 that has group permissions. If it already exists, add group permissions to all directories recursively.
create_shared_dir() {
  declare dir_path="${1}" user="${2}"

  if [[ ! -e "${dir_path}" ]]; then
    sudo -n "${user}" mkdir --parents --mode 0750 "${dir_path}"
  else
    sudo chmod -R g+rX "${dir_path}"
  fi
}

print_err() {
  printf '  ERROR: %s\n' "${@}" >&2
}

rocky_install_deps() {
  sudo dnf install "${rocky_deps}"
}

rocky_update() {
  sudo dnf update --assumeyes
}

# Uses SteamCmd to install game server via app_id $1 to directory $2
server_install() {
  declare app_id="${1}" dir_path="${2}"

  sudo -u "${steam_username}" steamcmd +force_install_dir "${dir_path}" +login anonymous +app_update "${app_id}" validate +exit
}

server_config() {
  source "${__dir}/server-${game_name}.sh"
}

# Download the SteamCmd archive to directory $1 from a web address $2
steamcmd_download() {
  declare dir_path="${1}" url="${2}"

  sudo -u "${steam_username}" wget --show-progress --directory-prefix "${dir_path}" "${url}"
}

steamcmd_init() {
  sudo -u "${steam_username}" steamcmd +login anonymous +quit
}

# Create a passthrough script in $PATH that points to the steamcmd script at $1
steamcmd_in_path() {
  declare script_path="${1}"
  local path_path="/usr/local/bin/steamcmd"

  sudo bash -c "cat > ${path_path}" <<EOF
#!/usr/bin/env bash

/usr/bin/env bash "${script_path}" "\${@}"

EOF

  sudo chmod 755 "${path_path}"
}

# Untars a file $1 to directory $2, then removes the tarfile.
steamcmd_unpack() {
  declare tar_path="${1}" target_dir="${2}"

  sudo -u "${steam_username}" tar -xzf "${tar_path}" -C "${target_dir}"
  sudo rm "${tar_path}"
}

##########
#  Main  #
##########

main() {
  # Safety Checks
  preflight

  # User/Environment setup
  create_steamuser
  add_self_to_steamgroup
  create_shared_dir "${steamcmd_dir}" "${steam_username}"

  # Install SteamCMD
  rocky_update
  rocky_install_deps
  steamcmd_download "${steamcmd_dir}" "${steamcmd_url}"
  local steam_tar_path="${steamcmd_dir}/$(basename ${steamcmd_url})"
  steamcmd_unpack "${steam_tar_path}" "${steamcmd_dir}"
  steamcmd_to_path "${steamcmd_dir}/steamcmd.sh"
  steamcmd_init

  # Install Game Server
  create_shared_dir "${game_dir}" "${steam_username}"
  server_install "${game_steam_id}" "${game_dir}"
  server_config

}

# main "${@}"

echo "farts"