#!/bin/bash -eux

# Create AMI Bundle
AMI_NAME="<%= @ami_name %>"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(aws configure get region)
# Note this will cause the instance to reboot.  Not using the --no-reboot flag
# to ensure consistent AMI creation.
SOURCE_AMI_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/ami-id)
echo "$SOURCE_AMI_ID" > /var/log/source-ami-id.txt
mkdir -p /opt/forger/data
aws ec2 create-image --name "$AMI_NAME" --instance-id "$INSTANCE_ID" --region "$REGION" > /opt/forger/data/ami-id.txt
