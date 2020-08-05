#!/bin/bash
# Copyright 2020 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Install and start the Google osconfig agent (google-osconfig-agent).
#
#


# Host that serves the repositories.
REPO_HOST='packages.cloud.google.com'

# URL documentation which lists supported platforms for running the osconfig agent.
OSCONFIG_AGENT_SUPPORTED_URL="https://cloud.google.com/compute/docs/os-config-management/create-guest-policy#supported_operating_systems"


if [[ -f /etc/os-release ]]; then
  . /etc/os-release
fi

handle_debian() {
  if [[ "${ID}" == debian && "${VERSION_ID}" == 9 ]]; then
    local CODENAME="stretch"
  elif [[ "${ID}" == debian && "${VERSION_ID}" == 10 ]]; then
    local CODENAME="buster"
  elif [[ "${ID}" == ubuntu && "${VERSION_ID}" == 16.04 ]]; then
    local CODENAME="xenial"
  elif [[ "${ID}" == ubuntu ]]; then  # 18.04 and later
    local CODENAME="bionic"
  fi

  local REPO_NAME="google-compute-engine-${CODENAME}-stable"
  cat > /etc/apt/sources.list.d/google-compute-engine.list <<EOM
deb http://${REPO_HOST}/apt ${REPO_NAME} main
EOM
  curl --connect-timeout 5 -s -f "https://${REPO_HOST}/apt/doc/apt-key.gpg" | apt-key add -
  apt update
  apt -y install google-osconfig-agent
}

# Takes the repo codename as a parameter.
handle_rpm() {
  lsb_release -v >/dev/null 2>&1 || yum -y install redhat-lsb-core
  local REPO_NAME="google-osconfig-agent-${1}-stable"
  cat > /etc/yum.repos.d/google-compute-engine.repo <<EOM
[google-compute-engine]
name=Google Compute Engine Repository
baseurl=https://${REPO_HOST}/yum/repos/${REPO_NAME}
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://${REPO_HOST}/yum/doc/yum-key.gpg
       https://${REPO_HOST}/yum/doc/rpm-package-key.gpg
EOM
  sudo yum -y install google-osconfig-agent
}

handle_redhat() {
  local VERSION_PRINTER='import platform; print(platform.dist()[1].split(".")[0])'
  local MAJOR_VERSION="$(python2 -c "${VERSION_PRINTER}")"
  handle_rpm "el${MAJOR_VERSION}"
}

handle_suse() {
  SUSE_VERSION=${VERSION%%-*}
  local REPO_NAME="google-compute-engine-sles${SUSE_VERSION}-stable"
  # TODO: expand all short arguments in this script, for readability.
  zypper -n refresh || { \
    echo "Could not refresh zypper repositories."; \
    echo "This is not necessarily a fatal error; proceeding..."; \
  }
  zypper addrepo -g -t YUM "https://${REPO_HOST}/yum/repos/${REPO_NAME}" google-compute-engine
  rpm --import "https://${REPO_HOST}/yum/doc/yum-key.gpg" "https://${REPO_HOST}/yum/doc/rpm-package-key.gpg"
  zypper -n --gpg-auto-import-keys install google-osconfig-agent
}

case "${ID:-}" in
  debian|ubuntu)
    echo 'Adding agent repository for Debian or Ubuntu.'
    handle_debian
    ;;
  rhel|centos)
    echo 'Adding agent repository for RHEL or CentOS.'
    handle_redhat
    ;;
  sles)
    echo 'Adding agent repository for SLES.'
    handle_suse
    ;;
  *)
    echo >&2 'Unidentifiable or unsupported platform.'
    echo >&2 "See ${OSCONFIG_AGENT_SUPPORTED_URL} for a list of supported platforms."
    exit 1
esac
