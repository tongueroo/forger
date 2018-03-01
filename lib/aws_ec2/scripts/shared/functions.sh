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
