#!/bin/bash -eux

if [ $# -eq 0 ]; then
  command=$(basename "$0")
  echo "Usage: $command LOG_GROUP_NAME"
  echo "Examples:"
  echo "  $command forger"
  echo "  $command ec2"
  exit 1
fi
LOG_GROUP_NAME=$1

# shellcheck disable=SC1091
source "/opt/forger/shared/functions.sh"
OS=$(os_name)
if [ "$OS" != "amzn" ] && [ "$OS" != "amazonlinux2" ] && [ "$OS" != "ubuntu" ] ; then
  echo "Sorry, cloudwatch logging with the forger tool is supported for amazonlinux2 and ubuntu only"
  exit
fi

export OS # used by the scripts to delegate to the right OS script
/opt/forger/cloudwatch/install.sh
/opt/forger/cloudwatch/configure.sh "$LOG_GROUP_NAME"
/opt/forger/cloudwatch/service.sh
