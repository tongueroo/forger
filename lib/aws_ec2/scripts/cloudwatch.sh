#!/bin/bash -eux

if [ $# -eq 0 ]; then
  command=$(basename "$0")
  echo "Usage: $command LOG_GROUP_NAME"
  echo "Examples:"
  echo "  $command aws-ec2"
  echo "  $command ec2"
  exit 1
fi
LOG_GROUP_NAME=$1

source "/opt/aws-ec2/shared/functions.sh"
os=$(os_name)
if [ "$os" != "amazonlinux2" ]; then
  echo "Sorry, enable cloudwatch logging with the aws-ec2 tool is only supported for amazonlinux2 currently"
  exit
fi

/opt/aws-ec2/cloudwatch/install.sh
/opt/aws-ec2/cloudwatch/configure.sh "$LOG_GROUP_NAME"
/opt/aws-ec2/cloudwatch/service.sh
