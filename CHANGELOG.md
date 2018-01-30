# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [0.8.2]
- add compile_keep option

## [0.8.1]
- reorganize template helpers into core and update readme

## [0.8.0]
- aws-ec2 upload_scripts command
- rename aws-ec2 compile to aws-ec2 compile_scripts

## [0.7.0]
- Rid of name to profile convention, check profile exists and report to user
  if it does not exist. This is a more expected interface.

## [0.6.0]
- add scripts_s3_bucket config option
- halt script if hooks fail

## [0.5.2]
- remove byebug debugging

## [0.5.1]
- show a friendly user message if not an aws-ec2 project

## [0.5.0]
- compile_scripts compiles both app/user-data and app/scripts

## [0.4.0]
- aws-ec2 ami command
- create: add --source-ami options
- compile_scripts command
- custom helper support
- dotenv support
- hook support
- latest_ami helper
- partial support
- starter specs: spec for ami
- remove aws-ec2 spot command
- remove aws-ec2 userdata command, sanity rspec passing

## [0.3.0]
- Do not merge profile to default profile.  This was pretty confusing usage.
- Add --ami option which result in automatically creating an ami at the end of
  the user-data script.

## [0.2.0]
- Add config files support. example: config/development.yml.

## [0.1.0]
- Initial release.
