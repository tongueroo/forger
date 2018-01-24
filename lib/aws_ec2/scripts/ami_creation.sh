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

# The aws ec2 create-image command below reboots the instance.
# So before rebooting the instance, schedule a job to terminate the instance
# in 20 mins after the machine has rebooted
cat >~/terminate-myself.sh <<EOL
#!/bin/bash -exu
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids \$INSTANCE_ID
EOL
# at now + 1 minutes -f ~/terminate-myself.sh

# Create AMI Bundle
AMI_NAME="<%= @ami_name %>"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(aws configure get region)
aws ec2 create-image --name $AMI_NAME --instance-id $INSTANCE_ID --region $REGION
