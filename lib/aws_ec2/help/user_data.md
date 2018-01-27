Displays the generated user data script. Useful for debugging since ERB can be ran on the user-data scripts.

Given a user data script in app/user-data/myscript.sh, run:

  $ aws-ec2 userdata myscript

You can have an ami creation snippet of code added to the end of the user data script with the `--ami` option.

  $ aws-ec2 userdata myscript --ami myname

If you want to include a timestamp in the name you can use this:

  $ aws-ec2 userdata myscript --ami '`date "+myname_%Y-%m-%d-%H-%M"`'
