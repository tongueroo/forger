#!/bin/bash

# Key is that instance will not be terminated if source image is the same as the
# original image id.
function terminate_instance() {
  local SOURCE_AMI_ID
  local AMI_ID

  SOURCE_AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
  AMI_ID=$(cat /opt/forger/data/ami-id.txt | jq -r '.ImageId')
  if [ "$SOURCE_AMI_ID" = "$AMI_ID" ]; then
    echo "The source ami and ami_id are the same: $AMI_ID"
    echo "Will not terminate the instance for this case."
    echo "This case can happen when an /etc/rc.local script to auto-terminate the "
    echo "instance was capture from a previous AMI build."
    return
  fi

  INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  SPOT_INSTANCE_REQUEST_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq -r '.Reservations[].Instances[].SpotInstanceRequestId')

  # jq returns null
  if [ "$SPOT_INSTANCE_REQUEST_ID" != "null" ]; then
    cancel_spot_request
  fi
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

# When image doesnt exist at all, an empty string is returned.
function ami_state() {
  local ami_id
  ami_id=$1
  aws ec2 describe-images --image-ids "$ami_id" --owners self | jq -r '.Images[].State'
}

function wait_for_ami() {
  local name
  name=$1

  local x
  local state
  x=0

  state=$(ami_state "$name")
  while [ "$x" -lt 10 ] && [ "$state" != "available" ]; do
    x=$((x+1))

    state=$(ami_state "$name")
    echo "state $state"
    echo "sleeping for 60 seconds... times out at 10 minutes total"

    type sleep
    sleep 60
  done

  echo "final state $state"
}

function terminate() {
  local when
  when=$1

  export PATH=/usr/local/bin:$PATH # for jq

  if [ "$when" == "later" ]; then
    terminate_later
  elif [ "$when" == "after_ami" ]; then
    terminate_after_ami
  elif [ "$when" == "after_timeout" ]; then
    terminate_after_timeout
  else
    terminate_now
  fi
}

function terminate_later() {
  schedule_termination
}

# This gets set up at the very beginning of the user_data script.  This ensures
# that after a 45 minute timeout the instance will get cleaned up and terminated.
function terminate_after_timeout() {
  rm -f /opt/forger/data/ami-id.txt # rm file possible stale file from previous ami

  # Remove all old at jobs.
  # Assume all at job are previous after_timeout.sh job from previous AMI.
  # Note: Each new at job increments the id by 1.  So each AMI will have a different
  # at job number.
  for i in $(atq | awk '{print $1}') ; do
    at -r $i
  done
  echo "/opt/forger/auto_terminate/after_timeout.sh now" | at now + 45 minutes
}

function terminate_after_ami() {
  local AMI_ID

  unschedule_termination
  AMI_ID=$(cat /opt/forger/data/ami-id.txt | jq -r '.ImageId')
  if [ -n "$AMI_ID" ]; then
    # wait for the ami to be successfully created before terminating the instance
    # https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/image-available.html
    # It will poll every 15 seconds until a successful state has been reached. This will exit with a return code of 255 after 40 failed checks.
    # so it'll wait for 10 mins max
    # aws ec2 wait image-available --image-ids "$AMI_ID" --owners self

    # For some reason aws ec2 wait image-available didnt work for amazonlinux2
    # so using a custom version
    wait_for_ami "$AMI_ID"
  fi

  terminate_instance
}

function terminate_now() {
  terminate_instance
}

source "/opt/forger/shared/functions.sh"
os=$(os_name)
source "/opt/forger/auto_terminate/functions/${os}.sh"
