Examples:

    forger create my-instance

To see the snippet of code that gets added to the user-data script you can use the `--noop` option and then view the generated tmp/user-data.txt.

    forger create myscript --noop

You can tell forger to wait until the instance is ready with the `--wait` option.

    forger create my-instance --wait

You can also tell forger to ssh into the instance immediately after it's ready with the `--ssh` option.  Examples:

    forger create my-instance --ssh # default is to login as ec2-user
    forger create my-instance --ssh --ssh-user ubuntu
    SSH_OPTIONS "-A" forger create my-instance --ssh --ssh-user ubuntu

## CloudWatch support

There is experimental support for CloudWatch logs.  When using the `--cloudwatch` flag, code is added to the very beginning of the user-data script so that logs of the instance are sent to cloudwatch.  Example:

    forger create my-instance --cloudwatch
