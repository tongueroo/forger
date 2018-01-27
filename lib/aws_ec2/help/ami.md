Examples:

  $ aws-ec2 ami myrubyami --profile ruby --noop

The launches an EC2 instance with using the profile running it's user-data script.  An ami creation script is appended to the end of the user-data script. The ami creation script uses the AWS CLI `aws ec2 create-image` command to create an AMI.  It is useful to include to timestamp as a part of the ami name with the date command.

  $ aws-ec2 ami $(date "+ruby-2.5.0_%Y-%m-%d-%H-%M") --profile ruby --noop

Note, it is recommended to use the `set -e` option in your user-data script so that if the script fails, the ami creation script is never reached and instance is left behind so you can debug.

The instance also automatically gets terminated and cleaned up.
