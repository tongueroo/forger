Examples:

    $ aws-ec2 wait ami --name ruby-2.5.0_2018-03-24-17-07
    $ aws-ec2 wait ami --id ami-b0138dc8

Polls the AMI with the given name or id is found and available.

### Timeout

Command times out after 30 mins by default.  You can control the timeout with the `--timeout` flag.  The timeout is specified in seconds.

    $ aws-ec2 wait ami --id ami-b0138dc8 --timeout 3600