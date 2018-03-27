#!/bin/bash -exu

# yum install already has configured
#   /usr/lib/systemd/system/awslogsd.service
# Restart because we adjust the config with configure.sh
# The yum awslogs package creates a systemd unit called awslogsd.
systemctl daemon-reload
systemctl restart awslogsd
systemctl enable awslogsd
# systemctl status awslogsd
