# AWS EC2 Tool

Simple tool to create AWS ec2 instances with in a consistency way with pre-configured settings.  The pre-configured settings are stored in files in the profiles folder of the current directory.
For example, say you have:

* profiles/default.yml
* profiles/myserver.yml

Then `myserver.yml` gets combined with `default.yml` profile.  The `default.yml` takes the lowest precedence.

## Usage

```sh
$ aws-ec2 create myserver --profile myserver
```

## Convention

By convention, the profile is name of the db.  So the command above could be shortened to:

```
$ aws-rds create myserver
```

## User-Data

You can provide you own custom user-data script to customize the server upon launch.  The user data scripts are under the profiles/user-data folder.

* profiles/user-data/myserver.yml

To use the the user-data

## Installation

```sh
gem install aws-rds
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
