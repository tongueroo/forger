#!/bin/bash -exu

# yum install already has configured
#   /usr/lib/systemd/system/awslogsd.service
# Restart because we adjust the config with configure.sh
systemctl daemon-reload
systemctl restart awslogsd # with the yum awslogs package the systemd is called awslogsd
# systemctl status awslogsd
