# AWS EC2 Tool

Simple tool to create AWS ec2 instances consistently with pre-configured settings.  The pre-configured settings are stored in the profiles folder of the current project directory.
Example:

* profiles/default.yml: Default settings. Used when no profile is specified.
* profiles/myserver.yml: myserver profile.  Used when `--profile myserver` is specified.

## Usage

```sh
aws-ec2 create myserver --profile myserver
```

In a nutshell, the profile parameters are passed to the ruby aws-sdk [AWS::EC2::Client#run_instances](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Client.html#run_instances-instance_method) method.  This allows you to specify any parameter you wish that is available in the aws-sdk. To check out what a profile looks like check out [example default](example/profiles/default.yml)

You can use ERB in the profile files. Some useful helper methods are documented here:

Helper  | Description
------------- | -------------
user_data | Allows you to embed a generated user_data script.  More details on the user-data are provided in the user data section below.
config | Access to the variables set in config/[AWS_EC2_ENV].yml.  Examples are `config/development.yml`, `config/staging.yml`, and `config/production.yml`.
latest_ami | Returns an AMI id by searching the ami name pattern and sorting in reverse older.  Example: `latest_ami("ruby-2.5.0_*")` would return the latest ruby AMIs are named with timestamps at the end like so: `ruby-2.5.0_2018-01-30-05-36-02` and `ruby-2.5.0_2018-01-29-05-36-02`.
search_ami | Returns a collection of AMI image objects based on a search pattern. The query searches on the AMI name.

For a full list of all the template helpers checkout: [aws_ec2/template_helper](lib/aws_ec2/template_helper).

You can also define custom helpers in the `app/helpers` folder as ruby modules with the naming convention `*_helper.rb`.  Example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.  Custom helpers are first-class citizens and have access to the same variables, methods and scope as built-in helpers.

## Noop mode

You can do a test run with the `--noop` flag.  This will print out what settings will be used to launch the instance.  This is one good way to inspect the generated user-data script.

```sh
aws-ec2 create myserver --profile myserver --noop
cat tmp/user-data.txt # to view generated user-data script
```

## Project Structure

Directory  | Description
------------- | -------------
app/helpers  | Custom helpers methods.  Define them as modules and their methods available whenever ERB is available: `config`, `profiles`, `app/scripts`, `app/user-data` files, etc. Example, you would define a `module FooHelper` in `app/helpers/foo_helper.rb`.
app/partials  | Your partials that can be use to be included in other scripts.  This is used in conjunction with the `partial` helper method.
app/scripts  | Where you define common scripts that can be used to configure the server. These scripts can be automatically uploaded to an s3 bucket for later downloading in your user-data script by setting the `scripts_s3_bucket` config option.
app/user-data  | Your user-data scripts that are used to bootstrap EC2 instance.
config/[AWS_EC2_ENV].yml  | The config file where you set configs that you want available in your templating logic.  Examples are: `config/development.yml`, `config/staging.yml`, or `config/production.yml`. You access the config with the `<%= config["var"] %>` helper.
profiles  | Your profile files.  These files mainly contain parameters that are passed to the aws-sd2 run_instances API.
tmp  | Where the generated scripts get compiled to. You can manually invoke the complilation via `aws-ec2 compile` if you wish to inspect what is generated, though this is automatically done as part of the `aws-ec2` create command.

## User-Data

You can provide a user-data script to customize the server upon launch.  The user-data scripts are located under the `app/user-data` folder.  Example:

* app/user-data/myserver.yml

The user-data script is generated on the machine that is running the aws-ec2 command. If this is your local macosx machine, then the context of your local macosx machine is available. To see the generated user-data script, you can use the run the create command in noop mode and then inspect the generated script.  Example:

```sh
aws create myserver --noop
cat /tmp/aws-ec2/user-data.txt
```

To use the user-data script when creating an EC2 instance, you use the `user_data` helper method in the profile.  Here's a grep of an example profile that uses the helper to show you want it looks like:

```
$ grep user_data profiles/default.yml
user_data: "<%= user_data("bootstrap") %>"
```

### Config

You can set variables in a config file and they are available when ERB is available, which are your profiles, user_data, scripts, etc.  Example `config/development.yml`:

```yaml
---
vpc_id: vpc-123
db_subnet_group_name: default
  - subnet-123
  - subnet-456
  - subnet-789
security_group_ids:
  - sg-123
scripts_s3_bucket: mybucket # enables s3 uploading of generated app/scripts
# compile_clean: true # uncomment to automatically remove the
                      # compiled scripts in tmp after aws-ec2 create
```

The variables are accessed via the `config` helper method. Here's a filtered example where it shows shows the relevant part of a profile: `profiles/default.yml`:

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
scripts_s3_bucket | Set this to the bucket name where you want the generated scripts in app/scripts and app/user-data to be automatically sync.  The sync happens right before the the internal call to run_instances that launches the instance.  If you need more custom logic, you can use the `before_run_instances` hook, covered in the Hooks section.

## Dotenv File Support

You can set and configure environment variables in `.env*` files.  Examples of this is in the [doc/example](doc/example) project.

### Hooks

There is only one hook: before_run_instances.  You can configure this with `config/hooks.yml`:  Example:

```
---
before_run_instances: /path/to/my/script.sh
```

This will run `/path/to/my/script.sh` as a shelled out command before the `run_instances` call.

## AMI Creation

To create AMIs you can use the `aws-ec2 ami` command.  This command launches an EC2 instance with the specified profile and create an AMI after the user-data script completes successfully. It does this by adding an AMI creation script at the end of the user-data script.  It is recommended to use the `set -e` option so that any error halts the script and the AMI does not get created.

After the AMI is created successfully, the instance will also terminate itself automatically so you do not have to worry about cleanup.  For more help run `aws-ec2 ami help`.

## Spot Instance Support

Spot instance is natively supported by the AWS run_instances command.  So, simply add `instance_market_options` to the parameters to request for a spot instance.  The available spot market options are available here:

* [https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_LaunchTemplateSpotMarketOptionsRequest.html)
* [https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Types/SpotMarketOptions.html)

An example of a spot instance profile is provided in [doc/example/profiles/spot.yml](doc/example/profiles/spot.yml).

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
