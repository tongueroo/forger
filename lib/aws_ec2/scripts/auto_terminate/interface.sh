#!/bin/bash
function source_os_interface() {
  local os
  os=$(os_name)
  # shellcheck disable=SC1090
  source "/opt/aws-ec2/auto_terminate/interface/${os}.sh"
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
# Usage:
#   source /opt/aws-ec2/auto_terminate/interface.sh
source_os_interface # called immedinately when:
