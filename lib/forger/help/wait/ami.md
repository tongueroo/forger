Examples:

    $ forger wait ami ruby-2.5.0_2018-03-24-17-07
    $ forger wait ami ami-b0138dc8

Polls the AMI with the given AMI name or id until AMI is found and available.

### Timeout

Command times out after 30 mins by default.  You can control the timeout with the `--timeout` flag.  The timeout is specified in seconds.

    $ forger wait ami --id ami-b0138dc8 --timeout 3600
