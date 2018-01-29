# AWS EC2 Tool

Simple tool to create AWS ec2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current directory.
Example:

* profiles/default.yml: default settings.
* profiles/myserver.yml: myserver settings.

## Usage

```sh
aws-ec2 create myserver --profile myserver
```

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  So you can specify any parameter you wish that is available there. To check out what a profile looks like look at the [example default](example/profiles/default.yml)

You can use ERB in the profile files. Some useful helper methods in the profile files are documented here:

Helper  | Description
------------- | -------------
user_data | Allows you to embed a generated user_data script.  More details on the are provided in the user data section below.
config | Access to the variables set in config/[AWS_EC2_ENV].yml.
latest_ami | Returns an AMI id by searching the ami name pattern and sorting in reverse older.  Example: `latest_ami("ruby-2.5.0_*")`
search_ami | Returns a collection of AMI image objects based on a search pattern. The query searches on the AMI name.

The template helpers defined in:

* [aws_ec2/template_helper.rb](lib/aws_ec2/template_helper.rb).
* [aws_ec2/template_helper](lib/aws_ec2/template_helper).

You can also define your own custom helpers in the `app/helpers` folder as ruby modules with the naming convention `'*_helper.rb`.  Example, the module FooHelper  should be defined in `app/helpers/foo_helper.rb`.  The custom helpers are first class citizens and have access to the same variables and methods as built in helpers.

### Convention

By convention, the profile name matches the first parameter after the create command.  So the command above could be shortened to:

```
aws-ec2 create myserver
```

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.  This is a good way to inspect the generated user-data script.

```sh
aws-ec2 create myserver --profile myserver --noop
```

## Project Structure

Directory  | Description
------------- | -------------
app/helpers  | Your own custom helpers methods.  Define them in modules and the methods made available to your `config`, `profiles`, `app/scripts`, `app/user-data` files.
app/partials  | Your partials that can be use to be included in other scripts.  This is used in conjunction with the partial helper method.
app/scripts  | Where you define common scripts that can be used to configure the server.
app/user-data  | Your user-data scripts that are used to bootstrap EC2 instance.
config/[AWS_EC2_ENV].yml  | AWS_EC2_ENV can be development, staging or production. Use this config file to set configs that you want available in your templating logic.
profiles  | Your profile files.  These files mainly contain parameters that are passed to the aws-sd2 run_instances API.
tmp  | Where the generated scripts get compiled to. You can manually invoke the complilation via `aws-ec2 compile`.

## User-Data

You can provide user-data script to customize the server upon launch.  The user-data scripts are under the app/user-data folder.

* app/user-data/myserver.yml

The user-data script is generated on the machine that is running the aws-ec2 command. If this is your local macosx machine, then the context is your local macosx machine is available. To see the generated user-data script, you can use the run the create command in noop mode and then inspect the generated script.  Example:

```sh
aws create myserver --noop
cat /tmp/aws-ec2/user-data.txt
```

To use the user-data script when creating an EC2 instance, you can use the helper method in the profile.  Here's a grep of a profile that users the helper:

```
$ grep user_data profiles/default.yml
user_data: "<%= user_data("bootstrap") %>"
```

### Config

You can set a config file and define variables in there that are available to in your profiles and user_data scripts.  Example `config/development.yml`:

```yaml
---
vpc_id: vpc-123
db_subnet_group_name: default
  - subnet-123
  - subnet-456
  - subnet-789
security_group_ids:
  - sg-123
s3_bucket: mybucket # for the user-data shared scripts
```

The variables are accessible via the `config` helper method. Example (only showing the part of the profile), `profiles/default.yml`:

```yaml
image_id: ami-4fffc834 # Amazon Lambda AMI
instance_type: t2.medium
security_group_ids: <%= config["security_group_ids"] %>
subnet_id: <%= config["subnets"].shuffle %>
...
```

## Dot Env File Support

You can set and configure environment variables in `.env*` files.  Examples of this is in the [doc/example](doc/example) project.

### Hooks

There is only one hook: before_run_instances.  You can configure this with `config/hooks.yml`:  Example:

```
---
before_run_instances: /path/to/my/script.sh
```

## Spot Instance Support

Spot instance support natively supported by the AWS run_instances command.  Simply add `instance_market_options` to the parameters to request for a spot instance.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

## More Help

```sh
aws-ec2 create help
aws-ec2 ami help
aws-ec2 compile help
aws-ec2 help # general help
```

Examples are in the [doc/example](doc/example) folder.  You will have to update settings like your subnet and security group ids.

## Installation

```sh
gem install aws-ec2
```

### Dependencies

This tool mainly uses the ruby aws-sdk but it does use the aws cli to check your region: `aws configure get region`. So it is dependent on the the `aws cli`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
