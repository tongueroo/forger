#!/bin/bash -exu

# This is another copy the /opt/aws-ec2/auto_terminate.sh script because the
# /opt/aws-ec2/auto_terminate.sh also gets removed when it gets called.  Specifically,
# it gets gets removed when "terminate after_ami" is called.

# There's this extra script that terminates after a timeout because sometimes:
#   1. the script stalls: IE: aws ec2 wait image-available and a custom wait_ami
#      does this.
#   2. the user_data script breaks and stops before finishing, never reaching
#      the terminate_later or terminate_now functions.
#

source /opt/aws-ec2/auto_terminate/functions.sh
# remove itself since at jobs survive reboots and if the ami gets created
# successfully we do not want this to be captured as part of the ami
rm -f /opt/aws-ec2/auto_terminate/after_timeout.sh
terminate now # hard code to now since only gets called via an at job
