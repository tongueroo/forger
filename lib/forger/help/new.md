## Examples

    forger new ec2 # project name is ec2 here
    cd ec2
    forger create box --noop # dry-run
    forger create box # live-run

Another project name:

    forger new projectname

## S3 Folder Option

    forger create box --s3 folder my-s3-bucket/my-folder

## VPC Option

    forger create box --vpc-id vpc-123

When the vpc-id option is not provided, forger uses the default vpc.

You can also set the security group and subnet id values explicitly instead:

    forger create box --subnet subnet-123
    forger create box --security-group sg-123
