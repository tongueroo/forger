Examples:

    $ aws-ec2 clean ami 'base-amazonlinux2*'
    $ aws-ec2 clean ami 'base-ubuntu*' --keep 5
    $ aws-ec2 clean ami 'base-ubuntu*' --noop # dry-run

Deletes old AMIs using the provided name as the base portion of the AMI name to search for.

Let's say you have these images:

    base-ubuntu_2018-03-25-04-20
    base-ubuntu_2018-03-25-03-39
    base-ubuntu_2018-03-25-02-57
    base-ubuntu_2018-03-25-02-47
    base-ubuntu_2018-03-25-02-43
    base-ubuntu_2018-03-23-00-15

Running:

    $ aws-ec2 clean ami 'base-ubuntu*'

Would delete all images and keep the 2 most recent AMIs.  The default `--keep` value is 2.  Make sure to surround the query pattern with a single quote to prevent shell glob expansion.
