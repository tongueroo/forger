#!/bin/bash -eux
# The shebang line is here in case there's is currently an empty user-data script.
# It wont hurt if already there.
######################################
# ami_creation.sh: added to the end of user-data automatically.
function configure_aws_cli() {
  local home_dir=$1
  # Configure aws cli in case it is not yet configured
  mkdir -p "$home_dir/.aws"
  if [ ! -f "$home_dir/.aws/config" ]; then
    cat >"$home_dir/.aws/config" <<EOL
[default]
region = <%= @region %>
output = json
EOL
  fi
}

configure_aws_cli /root

echo "############################################"
echo "# Logs above is from the original AMI baking at: $(date)"
echo "# New logs below"
echo "############################################"

# Create AMI Bundle
AMI_NAME="<%= @ami_name %>"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(aws configure get region)
# Note this will cause the instance to reboot.  Not using the --no-reboot flag
# to ensure consistent AMI creation.
SOURCE_AMI_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/ami-id)
echo "$SOURCE_AMI_ID" > /var/log/source-ami-id.txt
mkdir -p /opt/aws-ec2/data
aws ec2 create-image --name "$AMI_NAME" --instance-id "$INSTANCE_ID" --region "$REGION" > /opt/aws-ec2/data/ami-id.txt
