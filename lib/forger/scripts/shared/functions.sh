#!/bin/bash

function configure_aws_cli() {
  local home_dir
  home_dir=${1:-/root} # default to /root
  # Configure aws cli in case it is not yet configured
  mkdir -p "$home_dir/.aws"
  EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
  EC2_REGION=${EC2_AVAIL_ZONE::-1}
  cat >"$home_dir/.aws/config" <<CONFIGURE_AWS_CLI
[default]
region = $EC2_REGION
output = json
CONFIGURE_AWS_CLI
}

# Normalize os name so we can delegate out to os specific scripts.
#
# Amazon Linux 2
#   $ cat /etc/os-release
#   NAME="Amazon Linux"
#   VERSION="2 (2017.12)"
#   ID="amzn"
#   ID_LIKE="centos rhel fedora"
#   VERSION_ID="2"
#   PRETTY_NAME="Amazon Linux 2 (2017.12) LTS Release Candidate"
#   ANSI_COLOR="0;33"
#   CPE_NAME="cpe:2.3:o:amazon:amazon_linux:2"
#   HOME_URL="https://amazonlinux.com/"
#
# Ubuntu
#   ubuntu@ip-172-31-6-8:~$ cat /etc/os-release
#   NAME="Ubuntu"
#   VERSION="16.04.3 LTS (Xenial Xerus)"
#   ID=ubuntu
#   ID_LIKE=debian
#   PRETTY_NAME="Ubuntu 16.04.3 LTS"
#   VERSION_ID="16.04"
#   HOME_URL="http://www.ubuntu.com/"
#   SUPPORT_URL="http://help.ubuntu.com/"
#   BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
#   VERSION_CODENAME=xenial
#   UBUNTU_CODENAME=xenial
#
# Note: Amazon Linux and Amazon Linux 2 have the same name
#
function os_name() {
  local OS
  local VERSION

  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macosx" # gawk not available on macosx usually
  else
    # https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
    # Method 1 works for amazonlinux and ubuntu
    # Method 3 the complex script, did not work for amazonlinux
    OS=$(gawk -F= '/^ID=/{print $2}' /etc/os-release)
  fi

  OS="${OS// /}" # remove spaces
  OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
  # https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
  OS="${OS#\"}" # remove leading "
  OS="${OS%\"}" # remove trailing "

  if [ "$OS" == "amazonlinux" ]; then
    VERSION=$(gawk -F= '/^VERSION/{print $2}' /etc/os-release)
    VERSION="${VERSION#\"}" # remove leading "
    if [[ "$VERSION" =~ ^2 ]] ; then
      OS="${OS}2"
    fi
  fi

  echo "$OS"
}

