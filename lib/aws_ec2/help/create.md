Examples:

$ aws-ec2 create my-instance

If you want to create an ami at the end of of a successful user-data script run you can use the `--ami` option. Example:

$ aws-ec2 create my-instance --ami myname

To see the snippet of code that gets added to the user-data script you can use the aws-ec2 userdata command.

$ aws-ec2 userdata myscript --ami myname
