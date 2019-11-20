# Forger

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

[![CircleCI](https://circleci.com/gh/tongueroo/forger.svg?style=svg)](https://circleci.com/gh/tongueroo/forger)

Tool to create AWS EC2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current project directory.
Example:

* profiles/default.yml: Default settings. Used when no profile is specified.
* profiles/myserver.yml: myserver profile.  Used when `--profile myserver` is specified.

## How It Works

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  This allows you to specify any parameter you wish that is available in the aws-sdk. To check out what a profile looks like check out [example default profile](docs/example/profiles/default.yml).

## Usage: Quick Start

    forger new ec2 # generates starter skeleton project
    cd ec2
    forger create myserver # creates instance

## Useful new options

By default, `forger new` generates a project with some starting values for the files in the `config` and `profiles` folders.  You likely want to edit these values using your own values. Things like security groups, subnets, iam role, and the s3_folder option are useful settings to modify.  You can also specify a lot of these values as a part of the `new` command. Example:

    forger new ec2 --security-group sg-11223344 --iam MyIamRole --key-name my-keypair --s3-folder my-bucket/my-folder

Notably, using the `--s3-folder` option generates a project that make use of the `app/scripts` files and inserts some bash code into your user-data script that downloads and extracts the files. For more help:

    forger new -h

## Usage: More Details

    forger create NAME --profile PROFILE
    forger create myserver --profile myserver

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.  This is one good way to inspect the generated user-data script.

    forger create myserver --profile myserver --noop
    cat /tmp/forger/ec2/user-data.txt # to view generated user-data script

## Conventional Profile Name

If there is a profile name that matches the EC2 specified instance name, you can omit the `--profile` flag. Example

    forger create webserver --profile webserver
    forger create webserver # same as above

It is useful to add a random string to the end of your server name, but not use it for the `--profile` flag.  Example:

    forger create myserver-abc --profile myserver
    forger create myserver-123 --profile myserver

You can use the `--randomize` option to do this automatically:

    forger create myserver --randomize

## Project Structure

Directory  | Description
------------- | -------------
app/helpers  | Custom helpers methods.  Define them as modules and their methods are made available whenever ERB is available: `profiles`, `app/scripts`, `app/user_data` files, etc. For example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.
app/partials  | Your partials that can to be included in other scripts.  This is used in conjunction with the `partial` helper method. With great power comes great responsibility.  It is recommended to use partials sparely to keep scripts more straightforward.
app/scripts  | Where you define common scripts that can be used to configure the server. These scripts can be automatically uploaded to an s3 bucket for later downloading in your user-data script by setting the `s3_folder` settings option.
app/user_data  | Your user-data scripts that are used to bootstrap EC2 instance.
app/user_data/layouts  | user-data scripts support layouts. You user-data layouts go in here.
config/[FORGER_ENV].yml  | The config file where you set configs that you want available in your templating logic.  Examples are: `config/variables/development.rb` and `config/variables/production.rb`. You access the config variables with ERB `<%= @var %>`.
profiles  | Your profile files.  These files mainly contain parameters that are passed to the aws-sdk run_instances API method.
tmp  | Where the generated scripts get compiled to. You can manually invoke the compilation via `forger compile` to inspect what is generated.  This is automatically done as part of the `forger` create command.

## Helpers

You can use ERB in the profile files. Some useful helper methods are documented here:

Helper  | Description
------------- | -------------
user_data | Allows you to embed a generated user_data script.  More details on the user-data are provided in the user data section below.
config | Access to the variables set in config/[AWS\_EC2\_ENV].yml.  Examples are `config/variables/development.rb` and `config/variables/production.rb`.
latest_ami | Returns an AMI id by searching the AMI name pattern and sorting in reverse order.  Example: `latest_ami("ruby-2.5.0_*")` would return the latest ruby AMIs are named with timestamps at the end like so: `ruby-2.5.0_2018-01-30-05-36-02` and `ruby-2.5.0_2018-01-29-05-36-02`.
search_ami | Returns a collection of AMI image objects based on a search pattern. The query searches on the AMI name.
extract_scripts | Use this in your bash script to extract the `app/scripts` files that get uploaded to s3.

For a full list of all the template helpers check out: [lib/forger/template/helper](lib/forger/template/helper).

You can also define custom helpers in the `app/helpers` folder as ruby modules with the naming convention `*_helper.rb`.  For example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.  Custom helpers are first-class citizens and have access to the same variables, methods, and scope as built-in helpers.

## User-Data

You can provide a user-data script to customize the server upon launch.  The user-data scripts are located under the `app/user_data` folder.  Example:

* app/user_data/myserver.yml

The user-data script is generated on the machine that is running the forger command. If this is your local macosx machine, then the context of your local macosx machine is available. To see the generated user-data script, you can run the create command in `--noop` mode and then inspect the generated script.  Example:

    forger create myserver --noop
    cat /tmp/forger/ec2/user-data.txt

Another way to view the generated user-data scripts is the `forger compile` command.  It generates the files in the `tmp` folder.  Example:

    forger compile # generates files in tmp folder

To use the user-data script when creating an EC2 instance, use the `user_data` helper method in the profile file.  Here's a grep of an example profile that uses the helper to show you want it looks like. Be sure to surround the ERB call with quotes because the user-data script context is base64 encoded.

    $ grep user_data profiles/default.yml
    user_data: "<%= user_data("bootstrap") %>"

### User-Data Layouts

Refer to [docs/layouts.md](docs/layouts.md)

### Config

You can set variables in a config file and they are available when ERB is available: profiles, user-data, scripts, etc.  Example `config/variables/development.rb`:

```yaml
---
subnets:
  - subnet-123
  - subnet-456
  - subnet-789
security_group_ids:
  - sg-123
```

The variables are accessed via the `config` helper method. Here's a filtered example where it shows the relevant part of a profile: `profiles/default.yml`:

```yaml
image_id: ami-4fffc834 # Amazon Lambda AMI
instance_type: t2.medium
security_group_ids: <%= @security_group_ids %>
subnet_id: <%= @subnets.shuffle %>
...
```

### Settings

A `config/settings.yml` file controls the internal behavior of forger. It is different from config files which are meant for user defined varibles.  Settings variables are for internal use.  Example:

```yaml
development:
  # By setting s3_folder, forger will automatically tarball and upload your scripts
  # to set. You then can then use the extract_scripts helper method to download
  # the scripts onto the server.
  s3_folder: my-bucket/forger
  # compile_clean: true # uncomment to clean at the end of a compile
  # extract_scripts:
  #   to: "/opt"
  #   as: "ec2-user"

production:
```

### Hooks

There is only one hook: `before_run_instances`.  You can configure this with `config/hooks.yml`:  Example:

```yaml
---
before_run_instances: /path/to/my/script.sh
```

This will run `/path/to/my/script.sh` as a shelled out command before the `run_instances` call.

## Dotenv File Support

You can set and configure environment variables in `.env*` files.  Examples of this are in the [example](docs/example) project.  The env files are loaded in this order of precedence.

1. .env.[FORGER_ENV].local
2. .env.local
3. .env.[FORGER_ENV]
4. .env

An concrete example, `FORGER_ENV=development` (development is the default)

1. .env.development.local
2. .env.local
3. .env.development
4. .env

You are able to reference these values in the `config/[FORGER_ENV].yml` files with ERB.

## AMI Creation

To create AMIs you can use the `forger ami` command.  This command launches an EC2 instance with the specified profile and creates an AMI after the user-data script successfully completes. It does this by appending an AMI creation script at the end of the user-data script.  It is recommended to use the `set -e` option in your user-data script so that any error halts the script and the AMI does not get created.

After the AMI is successfully created, the instance will also terminate itself automatically so you do not have to worry about cleanup.  This is also done with an appended script. For more help run `forger ami help`.

For the instance to image and terminate itself, the EC2 IAM role for the instance requires IAM permissions for:

* aws ec2 create-image
* aws ec2 cancel-spot-instance-requests # in case a spot instance was used
* aws ec2 terminate-instances

## Spot Instance Support

Spot instance is natively supported by the AWS `run_instances` command by adding the `instance_market_options` to the parameters in the profile file.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

An example of a spot instance profile is provided in [example/profiles/spot.yml](docs/example/profiles/spot.yml).

## CloudWatch Support

The output of the logs like `/var/log/cloud-init-output.log` can get sent to CloudWatch. This gets enabled with the `--cloudwatch` flag.  Example:

    forger create myserver --cloudwatch

CloudWatch support only works for some OSes and is still somewhat experimental.  Here's the OS check in the source: [lib/forger/scripts/cloudwatch.sh](https://github.com/tongueroo/forger/blob/master/lib/forger/scripts/cloudwatch.sh#L16).

Note, CloudWatch logs take a few seconds to send from the EC2 instance to CloudWatch. So when using the `--auto-terminate` option the instance might be terminated before all the logs get sent.  So you might not capture all the logs. You can add a sleep 10 at the bottom of your user-data script if you think this is happening.

## More Help

    forger create help
    forger ami help
    forger compile help
    forger help # general help

Examples are in the [example](docs/example) folder.  You will have to update settings like your subnet and security group ids.

## Installation

    gem install forger

### Dependencies

This tool mainly uses the ruby aws-sdk. Though it does use the aws cli to check your region: `aws configure get region`. It also the uses `aws s3 sync` to perform the scripts upload. So it is dependent on the the `aws cli`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
