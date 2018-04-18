Examples:

    $ forger ami myrubyami --profile ruby --noop

Launches an EC2 instance to create an AMI.  An AMI creation script is appended to the end of the user-data script. The AMI creation script calls `aws ec2 create-image` and causes the instance to reboot at the end.

It is useful to include to timestamp as a part of the AMI name with the date command.

    $ forger ami ruby-2.5.0_$(date "+%Y-%m-%d-%H-%M") --profile ruby --noop

The instance also automatically gets terminated and cleaned up by a termination script appended to user-data.

It is recommended to use the `set -e` option in your user-data script so that if the script fails, the AMI creation script is never reached and the instance is left behind so you can debug.
