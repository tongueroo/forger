#!/bin/bash -eux

/opt/aws-ec2/auto_terminate/setup.sh

/opt/aws-ec2/auto_terminate.sh after_timeout
