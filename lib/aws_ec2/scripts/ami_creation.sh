#!/bin/bash -exu

# Configure aws cli in case it is not yet configured
mkdir -p /home/ec2-user/.aws
if [ ! -f /home/ec2-user/.aws/config ]; then
  cat >/home/ec2-user/.aws/config <<EOL
[default]
region = <%= region %>
output = json
EOL
fi

# Create AMI Bundle
AMI_NAME="<%= @ami_name %>"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 create-image --name $AMI_NAME --instance-id $INSTANCE_ID
