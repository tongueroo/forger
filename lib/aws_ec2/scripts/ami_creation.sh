#!/bin/bash -exu

# ami_creation.sh: added to the end of user-data automatically.

function configure_aws_cli() {
  local home_dir=$1
  # Configure aws cli in case it is not yet configured
  mkdir -p $home_dir/.aws
  if [ ! -f $home_dir/.aws/config ]; then
    cat >$home_dir/.aws/config <<EOL
[default]
region = <%= region %>
output = json
EOL
  fi
}

configure_aws_cli /home/ec2-user
configure_aws_cli /root

# The aws ec2 create-image command below reboots the instance.
# So before rebooting the instance, schedule a job to terminate the instance
# in 20 mins after the machine has rebooted
cat >~/terminate-myself.sh <<EOL
#!/bin/bash -exu
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids \$INSTANCE_ID
EOL
# at now + 1 minutes -f ~/terminate-myself.sh

echo "############################################" >> /var/log/user-data.log
echo "# Logs above is from the original AMI baking at: $(date)" >> /var/log/user-data.log
echo "# New logs below" >> /var/log/user-data.log
echo "############################################" >> /var/log/user-data.log

# Create AMI Bundle
AMI_NAME="<%= @ami_name %>"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(aws configure get region)
aws ec2 create-image --name $AMI_NAME --instance-id $INSTANCE_ID --region $REGION
