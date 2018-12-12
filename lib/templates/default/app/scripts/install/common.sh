#!/bin/bash

# https://forums.aws.amazon.com/thread.jspa?threadID=270511
(
  cd /tmp
  wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum install -y ./epel-release-latest-7.noarch.rpm
)

source /opt/scripts/shared/functions.sh
install_jq

# Some useful tools
yum install -y tree vim less
