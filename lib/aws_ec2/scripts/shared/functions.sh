#!/bin/bash

function configure_aws_cli() {
  local home_dir
  home_dir=${1:-/root} # default to /root
  # Configure aws cli in case it is not yet configured
  mkdir -p "$home_dir/.aws"
  if [ ! -f "$home_dir/.aws/config" ]; then
    EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    EC2_REGION=${EC2_AVAIL_ZONE::-1}
    cat >"$home_dir/.aws/config" <<CONFIGURE_AWS_CLI
[default]
region = $EC2_REGION
output = json
CONFIGURE_AWS_CLI
  fi
}

# Example OS values at this point:
#   Ubuntu
#   Amazon Linux AMI
function os_name() {
  # https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
  # Method 1 works for amazonlinux and ubuntu
  # Method 3 the complex script, did not work for amazonlinux
  local OS
  OS=$(gawk -F= '/^NAME/{print $2}' /etc/os-release) # text surrounded by double quotes
  # strip surrounding quotes: https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
  OS="${OS%\"}"
  OS="${OS#\"}"
  # Example OS values at this point:
  #   Ubuntu
  #   Amazon Linux AMI

  # normalize values
  case "$OS" in
    Ubuntu)
      echo "ubuntu"
      ;;
    *)
      echo "amazonlinux" # default
      ;;
  esac
}
