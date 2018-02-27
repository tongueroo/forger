# AWS EC2 Tool

[![CircleCI](https://circleci.com/gh/tongueroo/aws-ec2.svg?style=svg)](https://circleci.com/gh/tongueroo/aws-ec2)

Tool to create AWS ec2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current project directory.
Example:

* profiles/default.yml: Default settings. Used when no profile is specified.
* profiles/myserver.yml: myserver profile.  Used when `--profile myserver` is specified.

## Usage

```sh
aws-ec2 create NAME --profile PROFILE
aws-ec2 create myserver --profile myserver
```

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  This allows you to specify any parameter you wish that is available in the aws-sdk. To check out what a profile looks like check out [example default](docs/example/profiles/default.yml)

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.  This is one good way to inspect the generated user-data script.

```sh
aws-ec2 create myserver --profile myserver --noop
cat tmp/user-data.txt # to view generated user-data script
```

## Conventional Profile Name

If there is a profile name that matches the ec2 specified instance name, you can omit the `--profile` flag. Example

```sh
aws-ec2 create webserver --profile webserver
aws-ec2 create webserver # same thing as --profile whatever
```

It is useful to add a random string to the end of your server name, but not use it for the `--profile` flag.  Example:

```
aws-ec2 create myserver-abc --profile myserver
aws-ec2 create myserver-123 --profile myserver
```

You can use the `--randomize` option to do this automatically:

```
aws-ec2 create myserver --randomize
```

## Project Structure

Directory  | Description
------------- | -------------
app/helpers  | Custom helpers methods.  Define them as modules and their methods are made available whenever ERB is available: `profiles`, `app/scripts`, `app/user-data` files, etc. For example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.
app/partials  | Your partials that can to be included in other scripts.  This is used in conjunction with the `partial` helper method. With great power comes great responsibility.  It is recommended to use partials sparely to keep scripts more straightforward.
app/scripts  | Where you define common scripts that can be used to configure the server. These scripts can be automatically uploaded to an s3 bucket for later downloading in your user-data script by setting the `scripts_s3_bucket` config option.
app/user-data  | Your user-data scripts that are used to bootstrap EC2 instance.
config/[AWS_EC2_ENV].yml  | The config file where you set configs that you want available in your templating logic.  Examples are: `config/development.yml` and `config/production.yml`. You access the config variables with the `<%= config["var"] %>` helper.
app/user-data/layouts  | user-data scripts support layouts. You user-data layouts go in here.
profiles  | Your profile files.  These files mainly contain parameters that are passed to the aws-sdk run_instances API method.
tmp  | Where the generated scripts get compiled to. You can manually invoke the compilation via `aws-ec2 compile` to inspect what is generated.  This is automatically done as part of the `aws-ec2` create command.

## Helpers

You can use ERB in the profile files. Some useful helper methods are documented here:

Helper  | Description
------------- | -------------
user_data | Allows you to embed a generated user_data script.  More details on the user-data are provided in the user data section below.
config | Access to the variables set in config/[AWS_EC2_ENV].yml.  Examples are `config/development.yml` and `config/production.yml`.
latest_ami | Returns an AMI id by searching the AMI name pattern and sorting in reverse order.  Example: `latest_ami("ruby-2.5.0_*")` would return the latest ruby AMIs are named with timestamps at the end like so: `ruby-2.5.0_2018-01-30-05-36-02` and `ruby-2.5.0_2018-01-29-05-36-02`.
search_ami | Returns a collection of AMI image objects based on a search pattern. The query searches on the AMI name.

For a full list of all the template helpers check out: [aws_ec2/template_helper](lib/aws_ec2/template_helper).

You can also define custom helpers in the `app/helpers` folder as ruby modules with the naming convention `*_helper.rb`.  For example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.  Custom helpers are first-class citizens and have access to the same variables, methods, and scope as built-in helpers.

## User-Data

You can provide a user-data script to customize the server upon launch.  The user-data scripts are located under the `app/user-data` folder.  Example:

* app/user-data/myserver.yml

The user-data script is generated on the machine that is running the aws-ec2 command. If this is your local macosx machine, then the context of your local macosx machine is available. To see the generated user-data script, you can run the create command in `--noop` mode and then inspect the generated script.  Example:

```sh
aws-ec2 create myserver --noop
cat tmp/user-data.txt
```

Another way to view the generated user-data scripts is the `aws-ec2 compile` command.  It generates the files in the `tmp` folder.  Example:

```
aws-ec2 compile # generates files in tmp folder
```

To use the user-data script when creating an EC2 instance, use the `user_data` helper method in the profile file.  Here's a grep of an example profile that uses the helper to show you want it looks like. Be sure to surround the ERB call with quotes because the user-data script context is base64 encoded.

```
$ grep user_data profiles/default.yml
user_data: "<%= user_data("bootstrap") %>"
```

### User-Data Layouts

User-data scripts support layouts.  This is useful if you have common setup and finish code with your user-data scripts. Here's an example: `app/user-data/layouts/default.sh`:

```bash
#!/bin/bash
# do some setup
<%= yield %>
# finish work
```

And `app/user-data/box.sh`:

```
yum install -y vim
```

The resulting generated user-data script will be:

```bash
#!/bin/bash
# do some setup
yum install -y vim
# finish work
```

You can specify the layout to use when you call the `user_data` helper method in your profile. Example: `profiles/box.yml`:

```yaml
---
...
user_data: <%= user_data("box.sh", layout: "mylayout" ) %>
...
```

If there's a `layouts/default.sh`, then it will automatically be used without having to specify the layout option.  You can disable this behavior by passing in `layout: false` or by deleting the `layouts/default.sh` file.

### Config

You can set variables in a config file and they are available when ERB is available: profiles, user-data, scripts, etc.  Example `config/development.yml`:

```yaml
---
vpc_id: vpc-123
subnets:
  - subnet-123
  - subnet-456
  - subnet-789
security_group_ids:
  - sg-123
scripts_s3_bucket: mybucket # enables s3 uploading of generated app/scripts
# compile_clean: true # uncomment to automatically remove the
                      # compiled scripts in tmp after aws-ec2 create
```

The variables are accessed via the `config` helper method. Here's a filtered example where it shows the relevant part of a profile: `profiles/default.yml`:

```yaml
image_id: ami-4fffc834 # Amazon Lambda AMI
instance_type: t2.medium
security_group_ids: <%= config["security_group_ids"] %>
subnet_id: <%= config["subnets"].shuffle %>
...
```

#### Config Options

There are some config options that change the behavior of the ec2-aws:

Option | Description
--- | ---
scripts_s3_bucket | Set this to the bucket name where you want the generated scripts in app/scripts and app/user-data to be uploaded to.  The upload sync happens right before the internal to run_instances call that launches the instance.  If you need more custom logic, you can use the `before_run_instances` hook, covered in the Hooks section.

### Settings

A `config/settings.yml` file controls the internal behavior of aws-ec2. It is different from config files which are meant for user defined varibles.  Settings variables are for internal use.

### Hooks

There is only one hook: `before_run_instances`.  You can configure this with `config/hooks.yml`:  Example:

```
---
before_run_instances: /path/to/my/script.sh
```

This will run `/path/to/my/script.sh` as a shelled out command before the `run_instances` call.

## Dotenv File Support

You can set and configure environment variables in `.env*` files.  Examples of this are in the [example](docs/example) project.

## AMI Creation

To create AMIs you can use the `aws-ec2 ami` command.  This command launches an EC2 instance with the specified profile and creates an AMI after the user-data script successfully completes. It does this by appending an AMI creation script at the end of the user-data script.  It is recommended to use the `set -e` option in your user-data script so that any error halts the script and the AMI does not get created.

After the AMI is successfully created, the instance will also terminate itself automatically so you do not have to worry about cleanup.  This is also done with an appended script. For more help run `aws-ec2 ami help`.

For the instance to image and terminate itself, the EC2 IAM role for the instance requires IAM permissions for:

* aws ec2 create-image
* aws ec2 cancel-spot-instance-requests # in case a spot instance was used
* aws ec2 terminate-instances

## Spot Instance Support

Spot instance is natively supported by the AWS run_instances command.  So, simply add `instance_market_options` to the parameters to request for a spot instance.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

An example of a spot instance profile is provided in [example/profiles/spot.yml](docs/example/profiles/spot.yml).

## More Help

```sh
aws-ec2 create help
aws-ec2 ami help
aws-ec2 compile help
aws-ec2 help # general help
```

Examples are in the [example](docs/example) folder.  You will have to update settings like your subnet and security group ids.

## Installation

```sh
gem install aws-ec2
```

### Dependencies

This tool mainly uses the ruby aws-sdk. Though it does use the aws cli to check your region: `aws configure get region`. It also the uses `aws s3 sync` to perform the scripts upload. So it is dependent on the the `aws cli`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
