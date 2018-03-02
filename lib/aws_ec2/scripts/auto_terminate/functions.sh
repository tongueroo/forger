#!/bin/bash -eux

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

# When image doesnt exist at all, an empty string is returned.
function ami_state() {
  local name
  name=$1
  aws ec2 describe-images --filters "Name=name,Values=${name}" --owners self | jq -r '.Images[].State'
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
    sleep 1
    echo "hi"
  done

  echo "final state $state"
}

function terminate() {
  local when
  when=$1

  export PATH=/usr/local/bin:$PATH # for jq

  if [ "$when" == "later" ]; then
    terminate_later
  else
    terminate_now
  fi
}

function terminate_later() {
  schedule_termination
}

function terminate_now() {
  # Remove this script so it is only allowed to be ran once only, or when AMI is
  # launched, it will kill itself. This seems to be early enough to before it
  # gets captured in the AMI.
  rm -f /opt/aws-ec2/auto_terminate.sh
  unschedule_termination

  AMI_ID=$(cat /opt/aws-ec2/data/ami-id.txt | jq -r '.ImageId')
  if [ -n "$AMI_ID" ]; then
    # wait for the ami to be successfully created before terminating the instance
    # https://docs.aws.amazon.com/cli/latest/reference/ec2/wait/image-available.html
    # It will poll every 15 seconds until a successful state has been reached. This will exit with a return code of 255 after 40 failed checks.
    # so it'll wait for 10 mins max
    # aws ec2 wait image-available --image-ids "$AMI_ID" --owners self

    # For some reason aws ec2 wait image-available didnt work for amazonlinux
    # so using a custom version
    wait_for_ami "$AMI_ID"
  fi

  INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  SPOT_INSTANCE_REQUEST_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" | jq -r '.Reservations[].Instances[].SpotInstanceRequestId')

  if [ -n "$SPOT_INSTANCE_REQUEST_ID" ]; then
    cancel_spot_request
  fi
  terminate_instance
}

source "/opt/aws-ec2/shared/functions.sh"
os=$(os_name)
source "/opt/aws-ec2/auto_terminate/schedule/${os}.sh"
