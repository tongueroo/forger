#!/bin/bash -exu
# The shebang line is here in case there's is currently an empty user-data script.
# It wont hurt if already there.
##################
# auto_terminate.sh script
# When creating an AMI, a aws ec2 create-image command is added to the end of
# the user-data script. Creating AMIs prevent the script from going any further.
#
# To get around this the this is script is added before that happens.
#
# NOTE: this script depends on the aws cli being installed and that the server
# has IAM permission to terminate itself.
#

function create_interface_for_amazonlinux() {
  local path
  path=/opt/aws-ec2/auto_terminate/amazonlinux.sh
  mkdir -p $(dirname "$path")
  cat >"$path" << 'EOL'
#!/bin/bash
function schedule_termination() {
  chmod +x /etc/rc.d/rc.local
  echo "/opt/aws-ec2/auto_terminate.sh <%= @options[:ami_name] %> >> /var/log/terminate-myself.log 2>&1" >> /etc/rc.d/rc.local
}

function unschedule_termination() {
  grep -v terminate-myself /etc/rc.d/rc.local > /etc/rc.d/rc.local.tmp
  mv /etc/rc.d/rc.local.tmp /etc/rc.d/rc.local
}
EOL
}

function create_interface_for_ubuntu() {
  local path
  path=/opt/aws-ec2/auto_terminate/ubuntu.sh
  mkdir -p $(dirname "$path")
  cat >"$path" << 'EOL'
#!/bin/bash
function schedule_termination() {
  chmod +x /etc/rc.local
  sed -i 's/exit 0//' /etc/rc.local
  echo "/opt/aws-ec2/auto_terminate.sh <%= @options[:ami_name] %> >> /var/log/terminate-myself.log 2>&1" >> /etc/rc.local
}

function unschedule_termination() {
  grep -v terminate-myself /etc/rc.local > /etc/rc.local.tmp
  mv /etc/rc.local{.tmp,}
}
EOL
}

function create_interfaces() {
  create_interface_for_amazonlinux
  create_interface_for_ubuntu

  local path
  path=/opt/aws-ec2/auto_terminate/interfaces.sh
  mkdir -p $(dirname "$path")
  cat >"$path" << 'EOL'
#!/bin/bash
function source_os_interface() {
  local os
  os=$(os_name)
  # shellcheck disable=SC1090
  source "/opt/aws-ec2/auto_terminate/${os}.sh"
}

# Example OS values at this point:
#   Ubuntu
#   Amazon Linux AMI
function os_name() {
  # https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
  # Method 1 works for amazonlinux and ubuntu
  # Method 3 the complex script, did not work for amazonlinux
  local OS
  OS=$(gawk -F= '/^NAME/{print $2}' /etc/os-release) # text surrounded by double quotes
  # strip surrounding quotes: https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
  OS="${OS%\"}"
  OS="${OS#\"}"
  # Example OS values at this point:
  #   Ubuntu
  #   Amazon Linux AMI

  # normalize values
  case "$OS" in
    Ubuntu)
      echo "ubuntu"
      ;;
    *)
      echo "amazonlinux" # default
      ;;
  esac
}
source_os_interface
EOL
}


# install jq dependencies
function install_jq() {
  if ! type jq > /dev/null ; then
    wget "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
    mv jq-linux64 /usr/local/bin/jq
    chmod a+x /usr/local/bin/jq
  fi
}

function configure_aws_cli() {
  local home_dir
  home_dir=${1:-/root} # default to /root
  # Configure aws cli in case it is not yet configured
  mkdir -p "$home_dir/.aws"
  if [ ! -f "$home_dir/.aws/config" ]; then
    EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    EC2_REGION=${EC2_AVAIL_ZONE::-1}
    cat >"$home_dir/.aws/config" <<CONFIGURE_AWS_CLI
[default]
region = $EC2_REGION
output = json
CONFIGURE_AWS_CLI
  fi
}

function create_auto_terminate_script() {
  # https://stackoverflow.com/questions/27920806/how-to-avoid-heredoc-expanding-variables
  cat >/opt/aws-ec2/auto_terminate.sh << 'EOL'
#!/bin/bash -exu

function terminate_instance() {
  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
}

# on-demand instance example:
# $ aws ec2 describe-instances --instance-ids i-09482b1a6e330fbf7 | jq '.Reservations[].Instances[].SpotInstanceRequestId'
# null
# spot instance example:
# $ aws ec2 describe-instances --instance-ids i-08318bb7f33c216bd | jq '.Reservations[].Instances[].SpotInstanceRequestId'
# "sir-dzci5wsh"
function cancel_spot_request() {
  aws ec2 cancel-spot-instance-requests --spot-instance-request-ids "$SPOT_INSTANCE_REQUEST_ID"
}

function source_os_interface() {
  local os
  os=$(os_name)
  # shellcheck disable=SC1090
  source "/opt/aws-ec2/auto_terminate/${os}.sh"
}

# Example OS values at this point:
#   Ubuntu
#   Amazon Linux AMI
function os_name() {
  # https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
  # Method 1 works for amazonlinux and ubuntu
  # Method 3 the complex script, did not work for amazonlinux
  local OS
  OS=$(gawk -F= '/^NAME/{print $2}' /etc/os-release) # text surrounded by double quotes
  # strip surrounding quotes: https://stackoverflow.com/questions/9733338/shell-script-remove-first-and-last-quote-from-a-variable
  OS="${OS%\"}"
  OS="${OS#\"}"
  # Example OS values at this point:
  #   Ubuntu
  #   Amazon Linux AMI

  # normalize values
  case "$OS" in
    Ubuntu)
      echo "ubuntu"
      ;;
    *)
      echo "amazonlinux" # default
      ;;
  esac
}

########
# termination program starts here
export PATH=/usr/local/bin:$PATH

source /opt/aws-ec2/auto_terminate/interfaces.sh

# Remove this script so it is only allowed to be ran once ever
# Or else whenever we launch the AMI, it will kill itself. We do this early before
# waiting for the AMI to finish.  This is fast enough to before it gets captured in the
# AMI.
rm -f /opt/aws-ec2/auto_terminate.sh
unschedule_termination

AMI_NAME=$1
if [ "$AMI_NAME" != "NO-WAIT" ]; then
  # wait for the ami to be successfully created before terminating the instance
  # https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/image-available.html
  # It will poll every 15 seconds until a successful state has been reached. This will exit with a return code of 255 after 40 failed checks.
  # so it'll wait for 10 mins max
  aws ec2 wait image-available --filters "Name=name,Values=$AMI_NAME" --owners self
fi

INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
SPOT_INSTANCE_REQUEST_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq -r '.Reservations[].Instances[].SpotInstanceRequestId')

if [ -n "$SPOT_INSTANCE_REQUEST_ID" ]; then
  cancel_spot_request
fi
terminate_instance
EOL
  chmod a+x /opt/aws-ec2/auto_terminate.sh
}


function setup() {
  mkdir -p /opt/aws-ec2/auto_terminate
  # create all interfaces upfront
  create_interfaces
  # install dependencies
  install_jq
  configure_aws_cli /root

  create_auto_terminate_script
}

######
# finally all the functions that create scripts are done. We can call things.
setup
source /opt/aws-ec2/auto_terminate/interfaces.sh

<% if @options[:auto_terminate] %>
  <% if @options[:ami_name] %>
schedule_termination
  <% else %>
/opt/aws-ec2/auto_terminate.sh NO-WAIT # terminate immediately
  <% end %>
<% end %>
