##################
# auto_terminate.sh script
# When creating an AMI, a aws ec2 create-image command is added to the end of
# the user-data script. Creating AMIs prevent the script going any further.
#
# To get around this the this is script is added before that happens.
#
# https://stackoverflow.com/questions/27920806/how-to-avoid-heredoc-expanding-variables
cat >/root/terminate-myself.sh << 'EOL'
#!/bin/bash -exu

# install jq dependencies
function install_jq() {
  if ! type jq > /dev/null ; then
    wget "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
    mv jq-linux64 /usr/local/bin/jq
    chmod a+x /usr/local/bin/jq
  fi
}

function configure_aws_cli() {
  local home_dir=$1
  # Configure aws cli in case it is not yet configured
  mkdir -p $home_dir/.aws
  if [ ! -f $home_dir/.aws/config ]; then
    EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
    cat >$home_dir/.aws/config <<CONFIGURE_AWS_CLI
[default]
region = $EC2_REGION
output = json
CONFIGURE_AWS_CLI
  fi
}

function terminate_instance() {
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
}

# on-demand instance example:
# $ aws ec2 describe-instances --instance-ids i-09482b1a6e330fbf7 | jq '.Reservations[].Instances[].SpotInstanceRequestId'
# null
# spot instance example:
# $ aws ec2 describe-instances --instance-ids i-08318bb7f33c216bd | jq '.Reservations[].Instances[].SpotInstanceRequestId'
# "sir-dzci5wsh"
function cancel_spot_request() {
  aws ec2 cancel-spot-instance-requests --spot-instance-request-ids $SPOT_INSTANCE_REQUEST_ID
}

###
# program starts here
###
export PATH=/usr/local/bin:$PATH
install_jq
configure_aws_cli /root

AMI_NAME=$1

# wait for the ami to be successfully created before terminating the instance
# https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/image-available.html
# It will poll every 15 seconds until a successful state has been reached. This will exit with a return code of 255 after 40 failed checks.
# so it'll wait for 10 mins max
aws ec2 wait image-available --filters "Name=name,Values=$AMI_NAME" --owners self

INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
SPOT_INSTANCE_REQUEST_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | jq -r '.Reservations[].Instances[].SpotInstanceRequestId')

if [ -n "$SPOT_INSTANCE_REQUEST_ID" ]; then
  cancel_spot_request
fi
terminate_instance
EOL
chmod a+x /root/terminate-myself.sh

<% if @options[:auto_terminate] %>
<% if @options[:ami_name] %>
# schedule termination upon reboot
chmod +x /etc/rc.d/rc.local
echo "/root/terminate-myself.sh >> /var/log/terminate-myself.log 2>&1" >> /etc/rc.d/rc.local
<% else %>
# terminate immediately
/root/terminate-myself.sh >> /var/log/terminate-myself.log 2>&1
<% end %>
<% end %>
