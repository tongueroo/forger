# Extract Scripts

## Overview

Forger supports uploading files to s3 and making them available to your the launched EC2 instances.

## How it works

1. Add your scripts to the `app/scripts` folder.
2. In your user data script you called the helper method: `extract_scripts`

The `extract_scripts` in the user_data script can look something like this:

app/user_data/bootstrap.sh:

    #!/bin/bash

    <%= extract_scripts(to: "/opt") %>

The generates `extract_scripts` helper, generates a snippet of bash that looks something like this:

    mkdir -p /opt
    aws s3 cp s3://forger-bucket-EXAMPLE/development/scripts/scripts-md5.tgz /opt/
    (
      cd /opt
      rm -rf /opt/scripts
      tar zxf /opt/scripts-md5.tgz
      chmod -R a+x /opt/scripts
      chown -R ec2-user:ec2-user /opt/scripts
    )

It essentially extracts the scripts from the `app/scripts` to `/opt/scripts`.

## ERB Support

You can use ERB in the `app/scripts` files. So you can add dynamic logic based on ENV variables.

## S3 Bucket

Forger will automatically create the s3 bucket as needed. The s3 bucket is defined in the `forger` CloudFormation stack.
