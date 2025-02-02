#!/bin/bash

# User override-able variables:
# FACSPACK_MY_ENVS   - Parent dir of spack environment prefixes.
# FACSPACK_ENV_NAME  - Name of spack environment.

# Variables permitted to be used in `spack.yaml` environment files:
# FACSPACK_ENV            - Spack environment install prefix.
# FACSPACK_ENV_MODULEROOT - Spack environment moduleroot.
# FACSPACK_CONF_COMMON    - Site/Facility specific spack config files.
# FACSPACK_CONF_HOST      - Host-specific config spack files.
# FACSPACK_CONF_ENV       - Environment-specific spack config files.

#####################
# Obtain the path to this file.
#   `_THIS`  : path to this file
#   `_THIS_DIR`: path to parent directory of ${_THIS}
# First determine if script is sourced or executed
if [[ "$0" != "${BASH_SOURCE:-}" ]]; then
  # Script is sourced
  _SOURCED=1
  if [ -z "${BASH_SOURCE:-}" ]; then
    _THIS="$(which $0)"
  else
    _THIS="${BASH_SOURCE[0]}"
  fi
else
  # Script is executed
  _SOURCED=0
  _THIS="${BASH_SOURCE[0]}"
fi
while [ -h "$_THIS" ]; do
  # resolve $_THIS until the file is no longer a symlink
  _THIS_DIR="$( cd -P "$( dirname "$_THIS" )" >/dev/null && pwd )"

  # if $_THIS was a relative symlink, we need to resolve it relative to the
  # path where the symlink file was located
  _THIS="$(readlink "$_THIS")"
  [[ $_THIS != /* ]] && _THIS="$_THIS_DIR/$_THIS" 
done
_THIS_DIR="$( cd -P "$( dirname "$_THIS" )" >/dev/null && pwd )"
# Filter autofs-mangled /sw directories
_SW="/sw"
FACSPACK_SPACK_ROOT="${_THIS_DIR/#$(realpath $_SW)//sw}"
unset _SW
# Filter autofs-mangled $HOME directories
export FACSPACK_SPACK_ROOT="${FACSPACK_SPACK_ROOT/#$(realpath $HOME)/$HOME}"

#####################

# This script must be sourced.
[ ${_SOURCED} -eq 0 ] \
  && echo "ERROR: This script must be sourced!" \
  && echo "usage: '. ./init-facility-spack.sh'" \
  && exit 1

# Check if a spack instance is already setup in the environment. If so, do
# nothing and abort.
[[ -n "${SPACK_ROOT:-}" ]] \
  && echo "Spack is already initialized!" \
  && echo "  '${SPACK_ROOT}'" \
  && echo "Please restart shell to change configuration." \
  && return 1

# Identify the compute resource on which this spack instance is being
# initialized or fail.
_THIS_HOST="$(hostname --long \
             | sed -e 's/\.\(olcf\|ccs\)\..*//' \
                   -e 's/[-]\?\(login\|ext\|batch\|build\?\)[^\.]*[\.]\?//' \
                   -e 's/[-0-9]*$//' \
                   -e 's/head\.cm\.//')"
if [[ "${_THIS_HOST:-XX}" == "XX" ]]; then
  _THIS_HOST="$(sed -e 's/\.\(olcf\|ccs\)\..*//' \
                    -e 's/[-]\?\(login\|ext\|batch\|build\?\)[^\.]*[\.]\?//' \
                    -e  's/[-0-9]*$//' \
                    -e 's/cm\.//' /etc/hostname)"
fi
[[ "${_THIS_HOST:-XX}" == "XX" ]] \
  && echo "ERROR: Current host '${_THIS_HOST}' could not be identified!" \
  && return 1
export FACSPACK_HOST="${FACSPACK_HOST:-${_THIS_HOST}}"

# Define the location of the official facility-managed spack environments for
# this system. This env prefix is used by default unless overridden by the user.
_FS_DEFAULT_ENV_PREFIX="/sw/${FACSPACK_HOST}/spack-envs"
_FS_DEFAULT_ENV_NAME="base"
export FACSPACK_CONF_HOST="${FACSPACK_SPACK_ROOT}/hosts/${FACSPACK_HOST}"
export FACSPACK_CONF_COMMON="${FACSPACK_SPACK_ROOT}/share"

#_FS_SITE_SOURCE_CACHE="/sw/sources/facility-spack/source_cache"
#
# Tuguldur T. Odbadrakh
# 11/20/2023
# Changing sources dir to inside /sw/defiant/.testing for testing purposes
_FS_SITE_SOURCE_CACHE="${FACSPACK_ENV}/sources/source_cache"

if [ -e "${_FS_SITE_SOURCE_CACHE}" -a -w "${_FS_SITE_SOURCE_CACHE}" ]; then
  export FACSPACK_SOURCE_CACHE="${_FS_SITE_SOURCE_CACHE}"
else
  export FACSPACK_SOURCE_CACHE="${FACSPACK_CONF_COMMON}/mirrors/sources"
fi

# Setup the path to the spack environments prefix. All the spack envs for this
# system will be installed under this path. The path must be non-blank, exist,
# and be owned by the current user. The default value points to the production
# spack environments for this machine and can be over-ridden by the user for
# testing and private clones of the facility spack environments by setting the
# `FACSPACK_MY_ENVS` variable prior to sourcing this script.
export FACSPACK_MY_ENVS="${FACSPACK_MY_ENVS:-${_FS_DEFAULT_ENV_PREFIX}}"
_FS_ERR_MSG="ERROR: Environment prefix "
_FS_ERR_MSG+="'FACSPACK_MY_ENVS=${FACSPACK_MY_ENVS:-}'"
if [[ -z "${FACSPACK_MY_ENVS:-}" ]]; then
  echo  "${_FS_ERR_MSG} not set!"
  return 1
elif [[ ! -d "${FACSPACK_MY_ENVS:-}" ]]; then
  echo "${_FS_ERR_MSG} does not exist!"
  return 1
elif [[ "$(stat -c '%U' ${FACSPACK_MY_ENVS})" != ${USER} ]] && [[ ! "${USER}" =~ ^(m9b|belhorn|2ff|jmfinney|tok|todbadrakh)$ ]]; then
  echo "${_FS_ERR_MSG} is not owned by ${USER}!"
  return 1
fi
unset _FS_ERR_MSG

# Special case for OS upgrades
# FIXME: This should be restructured to reduce complexity and code duplication.
# Supporting two OSes simultaneously will require static core modulefiles tha
# alter the MODULEPATH to flexibly be aware of what spack platfrom to use, eg:
# 'linux-rhel7-ppc64le' vs 'linux-rhel8-ppc64le'
if [[ "${_THIS_HOST:-XX}" == "summit" ]]; then
   if [[ "$(grep VERSION_ID /etc/os-release)" =~ ^VERSION_ID=\"7 ]]; then
    _FS_DEFAULT_ENV_NAME="base-rh7"
    _FS_COPY_STATIC_MODULES="false"
   fi
elif [[ "${_THIS_HOST:-XX}" == "ascent" ]]; then
   if [[ "$(grep VERSION_ID /etc/os-release)" =~ ^VERSION_ID=\"7 ]]; then
    _FS_DEFAULT_ENV_NAME="base-rh7"
    _FS_COPY_STATIC_MODULES="false"
   fi
fi

# Select the name of the spack environment tracked in this repo for which the
# user will be modifying. All compute resources have a 'base' environment which
# is the default. This repo must contain a directory of this name among the envs
# for the current host. The default env name can be over-ridden by the user by
# setting the `FACSPACK_ENV_NAME` variable prior to sourcing this script.
export FACSPACK_ENV_NAME="${FACSPACK_ENV_NAME:-${_FS_DEFAULT_ENV_NAME}}"
export FACSPACK_CONF_ENV="${FACSPACK_CONF_HOST}/envs/${FACSPACK_ENV_NAME}"
if [ ! -d "${FACSPACK_CONF_ENV}" ]; then
  _FS_ERR_MSG="ERROR: Current host '${FACSPACK_HOST}' does not have "
  _FS_ERR_MSG+="an environment named 'FACSPACK_ENV_NAME=${FACSPACK_ENV_NAME}'!"
  echo "${_FS_ERR_MSG}"
  unset _FS_ERR_MSG
  return 1
fi

# Set the paths to the spack environment and modulefiles.
export FACSPACK_ENV="${FACSPACK_MY_ENVS}/${FACSPACK_ENV_NAME}"
export FACSPACK_ENV_MODULEROOT="${FACSPACK_ENV}/${FS_CUSTOM_MODULE_DIR:-modules}"

# Copy git-tracked modules to module root.
mkdir -p "${FACSPACK_ENV}/.mcache"
mkdir -p "${FACSPACK_ENV_MODULEROOT}"
[ ! -d "${FACSPACK_ENV_MODULEROOT}/site" ] && mkdir -p "${FACSPACK_ENV_MODULEROOT}/site"

if [[ "${_FS_COPY_STATIC_MODULES:-true}" == "true" ]]; then
  # FIXME: 
  #   Check and copy files one at a time:
  #     - if remote file is missing:
  #       - Print message about copy
  #       - Copy local to remote
  #     - else if diff/md5sum is different:
  #       - Print diff, permissions, uid/gid, and timestamps for both local and remote
  #         files
  #       - Prompt copy
  #     - else:
  #       - Print message that module is OK.
  if [ -d "${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site" ]; then
    echo "Checking static modulefiles..."
    (cd ${FACSPACK_ENV_MODULEROOT}/site && md5sum --check <(cd ${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site && find . -type f -exec md5sum {} + | sort -k 2))
    diff --color=always -u --recursive \
       "${FACSPACK_ENV_MODULEROOT}/site" \
       "${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site"
    xfertmp=$(mktemp) \
      && rsync --dry-run -crlp --out-format='RSYNC_CONFIRM %i %n%L' \
         "${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site/" \
         "${FACSPACK_ENV_MODULEROOT}/site/" \
         | grep "RSYNC_CONFIRM >" \
         | awk '{ print $3 }' > "${xfertmp}" \
      && echo "The following modulefiles and paths will be updated:" \
      && echo "+----------- > = sent; < = recieved; c = created; . = not updated; * = message" \
      && echo "|+---------- (d)irectory; (f)ile; (L)ink; (D)evice; (S)pecial" \
      && echo "||+--------- (c)hecksum changed" \
      && echo "|||+-------- (s)ize changed" \
      && echo "||||+------- (t)imestamp changed" \
      && echo "|||||+------ (p)permissions changed" \
      && echo "||||||+----- (o)wner changed" \
      && echo "|||||||+---- (g)roup changed" \
      && echo "||||||||+--- N/A" \
      && echo "|||||||||+-- (a)cl changed" \
      && echo "||||||||||+- (x)attr changed" \
      && echo "|||||||||||" \
      && rsync -n --itemize-changes --files-from=${xfertmp} \
         "${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site/" \
         "${FACSPACK_ENV_MODULEROOT}/site/"
    # TODO: Check envvar for non-interactive uses
    echo "Update modulefiles (y/[n])? "
    read
    if [[ ${REPLY} = [yY] ]]; then
      rsync -v --files-from=${xfertmp} \
           "${FACSPACK_CONF_HOST}/share/lmod/modulefiles/static/site/" \
           "${FACSPACK_ENV_MODULEROOT}/site/"
    fi
    rm -f "${xfertmp}"
  fi
else
  _FS_WARN_MSG="WARNING: Not updating static modulefiles.\n    "
  _FS_WARN_MSG+="Check that '${FACSPACK_ENV_MODULEROOT}/site/Core' "
  _FS_WARN_MSG+="contains appropriate core modules.\n"
  printf "${_FS_WARN_MSG}"
  unset _FS_WARN_MSG
fi

function setup_alternate_module_environment {
  # Detect if LMOD or TMOD
  local _msys="unknown"
  if [ -n "${LMOD_CMD:-}" ]; then
    _msys="lmod"
  elif [ -n "${MODULESHOME:-}" ] && [[ ! "${MODULESHOME:-x}" =~ lmod ]]; then
    _msys="tmod"
  else
    echo "WARNING: Could not determine module system. Aborting module setup."
    return
  fi
  # Setup alternate module environment
  if [[ "${_msys}" == "lmod" ]]; then
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
      module reset
      module purge
      echo "Using facility module root"
    else
      module reset
      module purge
      echo "Using custom module root '${FACSPACK_ENV_MODULEROOT}'"
      if [ -n "${1:-}" ]; then
        export MODULEPATH="$1"
      fi
    fi
  fi
  if [[ "${_msys}" == "tmod" ]]; then
    local _prgenv="$(module -t list 2>&1 | grep PrgEnv)"
    if [ -n "${_prgenv:-}" ]; then
      module unload ${_prgenv}
    fi
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
      echo "Using facility module root"
    fi
    else
      echo "Using custom module root '${FACSPACK_ENV_MODULEROOT}'"
      if [ -n "${1:-}" ]; then
        export MODULEPATH="$1"
      fi
  fi
}

# Host-specific environment modifications
case "${FACSPACK_HOST}" in
  summit)
    if [[ "${FACSPACK_ENV_NAME}" == "base-rh7" ]]; then
      _FS_MP="${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel7-ppc64le/Core"
    else
      _FS_MP="${_FS_MP:-${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel8-ppc64le/Core}"
    fi
    _FS_MP+=":${FACSPACK_ENV_MODULEROOT}/site/Core"
    _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles/core"
    setup_alternate_module_environment "${_FS_MP}"
    export MODULEPATH="${_FS_MP}"
    ;;
  ascent)
    if [[ "${FACSPACK_ENV_NAME}" == "base-rh7" ]]; then
      _FS_MP="${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel7-ppc64le/Core"
    else
      _FS_MP="${_FS_MP:-${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel8-ppc64le/Core}"
    fi
    _FS_MP+=":${FACSPACK_ENV_MODULEROOT}/site/Core"
    _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles/core"
    setup_alternate_module_environment "${_FS_MP}"
    export MODULEPATH="${_FS_MP}"
    ;;
  peak)
    _FS_MP="${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel8-ppc64le/Core"
    _FS_MP+=":${FACSPACK_ENV_MODULEROOT}/site/Core"
    _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles/core"
    setup_alternate_module_environment "${_FS_MP}"
    export MODULEPATH="${_FS_MP}"
    ;;
  andes)
    _FS_MP="${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel8-x86_64/Core"
    _FS_MP+=":${FACSPACK_ENV_MODULEROOT}/site/Core"
    _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles/core"
    setup_alternate_module_environment "${_FS_MP}"
    ;;
  lyra)
    _FS_MP="${FACSPACK_ENV_MODULEROOT}/spack/linux-rhel8-x86_64/Core"
    _FS_MP+=":${FACSPACK_ENV_MODULEROOT}/site/Core"
    # Next line replaced by following non-standard path:
    # _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles/core"
    _FS_MP+=":/sw/${FACSPACK_HOST}/modulefiles"
    _FS_MP+=":/opt/cray/pe/craype/default/modulefiles"
    _FS_MP+=":/opt/cray/pe/modulefiles"
    _FS_MP+=":/opt/cray/modulefiles"
    _FS_MP+=":/opt/modulefiles"
    _FS_MP+=":/etc/modulefiles"
    _FS_MP+=":/usr/share/modulefiles"
    _FS_MP+=":/usr/share/modulefiles/Linux"
    _FS_MP+=":/usr/share/modulefiles/Core"
    _FS_MP+=":/usr/share/lmod/lmod/modulefiles/Core"
    setup_alternate_module_environment "${_FS_MP}"
    ;;
  afw)
    export SPACK_FRONT_END="zen2"
    export SPACK_BACK_END="zen2"
    setup_alternate_module_environment "${_FS_MP}"
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
      echo "WARNING: AFW uses tcl environment modules which this script does not handle correctly"
    fi
    ;;
  #defiant)
  #  #export SPACK_FRONT_END="zen2"
  #  #export SPACK_BACK_END="zen2"
  #  #setup_alternate_module_environment "${_FS_MP}"
  #  if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
  #        && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
  #  fi
  #  ;;
  bones)
    export SPACK_FRONT_END="zen2"
    export SPACK_BACK_END="zen2"
    setup_alternate_module_environment "${_FS_MP}"
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
    module reset
    fi
    ;;
  borg)
    export SPACK_FRONT_END="zen3"
    export SPACK_BACK_END="zen3"
    setup_alternate_module_environment "${_FS_MP}"
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
    module reset
    fi
    ;;
  crusher)
    export SPACK_FRONT_END="zen3"
    export SPACK_BACK_END="zen3"
    export all_proxy="socks://proxy.ccs.ornl.gov:3128"
    export ftp_proxy="ftp://proxy.ccs.ornl.gov:3128"
    export http_proxy="http://proxy.ccs.ornl.gov:3128"
    export https_proxy="http://proxy.ccs.ornl.gov:3128"
    export HTTP_PROXY="http://proxy.ccs.ornl.gov:3128"
    export HTTPS_PROXY="http://proxy.ccs.ornl.gov:3128"
    export proxy="proxy.ccs.ornl.gov:3128"
    export no_proxy='localhost,127.0.0.0/8,*.ccs.ornl.gov,*.ncrc.gov'
    setup_alternate_module_environment "${_FS_MP}"
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
    module reset
    fi
    ;;
  frontier)
    export SPACK_FRONT_END="zen3"
    export SPACK_BACK_END="zen3"
    export all_proxy="socks://proxy.ccs.ornl.gov:3128"
    export ftp_proxy="ftp://proxy.ccs.ornl.gov:3128"
    export http_proxy="http://proxy.ccs.ornl.gov:3128"
    export https_proxy="http://proxy.ccs.ornl.gov:3128"
    export HTTP_PROXY="http://proxy.ccs.ornl.gov:3128"
    export HTTPS_PROXY="http://proxy.ccs.ornl.gov:3128"
    export proxy="proxy.ccs.ornl.gov:3128"
    export no_proxy='localhost,127.0.0.0/8,*.ccs.ornl.gov,*.ncrc.gov'
    setup_alternate_module_environment "${_FS_MP}"
    if [[ "${FACSPACK_MY_ENVS:-YY}" == "${_FS_DEFAULT_ENV_PREFIX:-XX}" \
          && "${FACSPACK_HOST}" == "${_THIS_HOST}" ]]; then
    module reset
    fi
    ;;
  *)
    ;;
esac

export PYTHONDONTWRITEBYTECODE=1
# FIXME - ensure spack instance submodule is checked out to appropriate commit
# WARNING - checking out new branches of spack while other instances are using
#           it will certainly cause problems. Need a way to lock the spack repo
#           while it is in use.
source "${FACSPACK_SPACK_ROOT}/spack/share/spack/setup-env.sh"
echo "Spack initialized for ${FACSPACK_HOST:-Unknown host} at ${SPACK_ROOT}"
spack env activate -d "${FACSPACK_CONF_ENV}"
