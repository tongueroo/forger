# AWS EC2 Tool

Simple tool to create AWS ec2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current directory.
Example:

* profiles/default.yml: default settings.  If there is no other matching profile.
* profiles/myserver.yml: myserver settings.

## Usage

```sh
aws-ec2 create myserver --profile myserver
```

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  So you can specify any parameter you wish that is available there. To check out what a profile looks like look at the [example default](example/profiles/default.yml)

You can use ERB in the profile files. Some useful helper methods in the profile files are:

* user_data: a helper method that allows you to embed a generated user_data script.  More details on the user_data helper are provided below.
* config:

The template helpers defined in [template_helper.rb](lib/aws_ec2/template_helper.rb).

### Convention

By convention, the profile name matches the first parameter after the create command.  So the command above could be shortened to:

```
aws-ec2 create myserver
```

## User-Data

You can provide user-data script to customize the server upon launch.  The user-data scripts are under the app/user-data folder.

* app/user-data/myserver.yml

The user-data script is generated on the machine that is running the aws-ec2 command. If this is your local macosx machine, then the context is your local macosx machine is available. To see the generated user-data script, you can use the `aws userdata NAME`.  Example:

* aws userdata myserver # shows a preview of the user-data script

To use the user-data script when creating an EC2 instance, you can use the helper method in the profile.

### Config

You can set a config file and define variables in there that are available to in your profiles and user_data scripts.

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.

```sh
aws-ec2 create myserver --profile myserver --noop
```

## Spot Instance Support

Spot instance support natively supported by the AWS run_instances command.  Simply add `instance_market_options` to the parameters to request for a spot instance.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

## More Help

```sh
aws-ec2 create help
aws-ec2 userdata help
aws-ec2 spot help
aws-ec2 help # general help
```

Examples are in the [example](example) folder.  You will have to update settings like your subnet and security group ids.

## Installation

```sh
gem install aws-ec2
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
