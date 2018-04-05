# EC2 Profiles

This folder contains EC2 profile files that can be used with the [forger](https://github.com/tongueroo/forger) tool to quickly launch EC2 instances consistently with some pre-configured settings.

## Create Test Instance

To create your own AWS EC2 instance for testing you can run:

	  forger create my-box --cloudwatch

This launches an instance and associates it with an route53 DNS record.

Note, you can run forger with `--noop` mode to preview the user-data script that the instance will launch with:

    forger create my-box --noop

### Verifying Bootstrap Process is Successful

You can verfiy that the instance has launched and completed its bootstraping scripting successfully with cloudwatch.  The command above should show you a cloudwatch log url to visit.  Here's an example with the output filtered to put the focus on the cloudwatch log message:

    $ forger create my-box --cloudwatch
    ...
    Spot instance request id: sir-sb5r4e1j
    EC2 instance my-box created: i-03f3c96eaec8ea359 🎉
    Visit https://console.aws.amazon.com/ec2/home to check on the status
    To view instance's cloudwatch logs visit:
      https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logEventViewer:group=ec2;stream=i-03f3c96eaec8ea359/var/log/cloud-init-output.log
      cw tail -f ec2 i-03f3c96eaec8ea359/var/log/cloud-init-output.log
    Note: It takes a little time for the instance to launch and report logs.
    Pro tip: The CloudWatch Console Link has been added to your copy-and-paste clipboard.
    $

Note, it is detected that the [cw](https://github.com/lucagrulla/cw) tool intalled on your machine it will also add that message.  The cw is a command line tool that allows you to tail the cloudwatch log from the terminal instead of the AWS console website.

## Setup .env File

There are some settings that are environment specific.  To configure these, copy the [.env.example](.env.example) file to `.env` and update them with your specific values.

You can have multiple .env files.  The load in this order of precendence.  You are able to reference these values in the `config/[FORGER_ENV].yml` files with ERB.

1. .env.[FORGER_ENV].local
2. .env.local
3. .env.[FORGER_ENV]
4. .env
