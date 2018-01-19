# AWS EC2 Tool

Simple tool to create AWS ec2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current directory.
Example:

* profiles/default.yml: default settings.  Takes the lowest precedence.
* profiles/myserver.yml: myserver settings get combined with the default settings

## Usage

```sh
aws-ec2 create myserver --profile myserver
```

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  So you can specify any parameter you wish that is available there. To check out what a profile looks look at the [example default](example/profiles/default.yml)

### Convention

By convention, the profile name matches the first parameter after the create command.  So the command above could be shortened to:

```
aws-ec2 create myserver
```

## User-Data

You can provide user-data script to customize the server upon launch.  The user-data scripts are under the profiles/user-data folder.

* profiles/user-data/myserver.yml

The user-data script is generated on the machine that is running the aws-ec2 command. If this is your local macosx machine, then the context is your local macosx machine is available. To see the generated user-data script, you can use the `aws userdata NAME`.  Example:

* aws userdata myserver # shows a preview of the user-data script

To use the user-data script when creating an EC2 instance, you can use the helper method in the profile.

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.

```sh
aws-ec2 create myserver --profile myserver --noop
```

## Spot Instance Support

Spot instance support natively supported by the AWS run_instances command.  Simply add `instance_market_options` to the parameters to request for a spot instance.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

## Spot Fleet Support

Additionally, spot fleet is supported.  Launching a fleet request is slighlyt more complicated but is useful if you are okay with multiple types of instances.  The spot instance profile files are stored in the profiles/spot folder.  Example:

* profiles/spot/default.yml: default settings.  Takes the lowest precedence.
* profiles/spot/myspot.yml: myspot settings get combined with the default settings

Note the parameters structure of a spot fleet request is different from the parameter structure to run a single instance with the create command above. The profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#request_spot_fleet](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#request_spot_fleet-instance_method) method.  So you can specify any parameter you wish that is available there.

```sh
ec2 spot myspot --profile myspot
ec2 spot myspot # same as above by convention
```

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
