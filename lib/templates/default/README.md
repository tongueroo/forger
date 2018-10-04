# EC2 Profiles

This folder contains EC2 profile files that can be used with the [forger](https://github.com/tongueroo/forger) tool to quickly launch EC2 instances consistently with some pre-configured settings.

## Generate a Forger Project

    forger new ec2 # project name is ec2
    cd ec2

## EC2 Box

Edit the `config/settings.yml` with an `s3_folder` so that forger can upload scripts to s3 as part of the creation process. These scripts are then made accessible to your user-data script with the `extract_scripts` helper.  Check out the generated `app/user_data/layouts/default.sh` to see an example of it.  It just downloads the scripts in `app/scripts` to the `/opt/folder`.  To see the `extract_scripts` generated script you can run create with the `--noop` command. An example is provided below.

To create an AWS EC2 instance you can run:

	forger create box

This launches an instance.

Note, you can run forger with `--noop` mode to preview the user-data script that the instance will launch with:

	forger create box --noop

### CloudWatch Support

You can also have forger insert a script to the generated user-data script that sends logs to CloudWatch with the `--cloudwatch` option.

	forger create box

It is useful to verfiy that the instance has launched and completed its bootstraping scripting successfully with cloudwatch.  The command above should show you a cloudwatch log url to visit.  Here's an example with the output filtered to put the focus on the cloudwatch log message:

    $ forger create box --cloudwatch
    ...
    Spot instance request id: sir-sb5r4e1j
    EC2 instance box created: i-03f3c96eaec8ea359 🎉
    Visit https://console.aws.amazon.com/ec2/home to check on the status
    To view instance's cloudwatch logs visit:
      https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logEventViewer:group=ec2;stream=i-03f3c96eaec8ea359/var/log/cloud-init-output.log
      cw tail -f ec2 i-03f3c96eaec8ea359/var/log/cloud-init-output.log
    Note: It takes a little time for the instance to launch and report logs.
    Pro tip: The CloudWatch Console Link has been added to your copy-and-paste clipboard.
    $

Note, it is is detected that the [cw](https://github.com/lucagrulla/cw) tool intalled on your machine it will also add that message.  The cw is a command line tool that allows you to tail the cloudwatch log from the terminal instead of the AWS console website.

## Setup .env File

There are some settings that are environment specific.  To configure these, copy the [.env.example](.env.example) file to `.env` and update them with your specific values.

You can have multiple .env files.  The load in this order of precendence.  You are able to reference these values in the `config/[FORGER_ENV].yml` files with ERB.

1. .env.[FORGER_ENV].local
2. .env.local
3. .env.[FORGER_ENV]
4. .env
