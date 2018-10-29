# EC2 Profiles

This folder contains EC2 profile files that can be used with the [forger](https://github.com/tongueroo/forger) tool to quickly launch EC2 instances consistently with some pre-configured settings.

## Generate a Forger Project

    forger new ec2 # project name is ec2
    cd ec2

## EC2 Box

To create an AWS EC2 instance you can run:

    forger create box

This launches an instance.

Note, you can run forger with `--noop` mode to preview the user-data script that the instance will launch with:

    forger create box --noop

## S3 App Scripts

The generated starter project creates some example `app/scripts` files.  The `app/scripts` are disabled until you configure the `s3_folder` setting `config/settings.yml` the `s3_folder` setting. 

The `app/scripts` files get uploaded to s3 as part of the `forger create` command.  You can use it in conjunction with the `extract_scripts` helper method in your user-data file. The `extract_scripts` helper generates a snippet of bash code that downloads and untars the files so user-data has access to the scripts. The scripts are extracted to `/opt/scripts` by default.  Be sure to add extract_scripts to your user-data script.

You can also specify the `--s3-folder` option as part of the `forger new` command to spare you from manually editing all the necessary files like `config/settings.yml` and the user-data scripts.

### CloudWatch Support

You can also have forger insert a script to the generated user-data script that sends logs to CloudWatch with the `--cloudwatch` option.

    forger create box

It is useful to verify that the instance has launched and completed its bootstrapping scripting successfully with cloudwatch.  The command above should show you a cloudwatch log url to visit.  Here's an example with the output filtered to put the focus on the cloudwatch log message:

    $ forger create box --cloudwatch
    ...
    Spot instance request id: sir-sb5r4e1j
    EC2 instance box created: i-03f3c96eaec8ea359 🎉
    Visit https://console.aws.amazon.com/ec2/home to check on the status
    To view instance's cloudwatch logs visit:
      https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logEventViewer:group=forger;stream=i-03f3c96eaec8ea359/var/log/cloud-init-output.log
      cw tail -f forger i-03f3c96eaec8ea359/var/log/cloud-init-output.log
    Note: It takes a little time for the instance to launch and report logs.
    Pro tip: The CloudWatch Console Link has been added to your copy-and-paste clipboard.
    $

Note, it is detected that the [cw](https://github.com/lucagrulla/cw) tool installed on your machine it will also add that message.  The cw is a command line tool that allows you to tail the cloudwatch log from the terminal instead of the AWS console website.

## Setup .env File

There are some settings that are environment specific.  To configure these, copy the [.env.example](.env.example) file to `.env` and update them with your specific values.

You can have multiple .env files.  The load in this order of precedence.  You are able to reference these values in the `config/[FORGER_ENV].yml` files with ERB.

1. .env.[FORGER_ENV].local
2. .env.local
3. .env.[FORGER_ENV]
4. .env
