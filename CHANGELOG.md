# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [1.4.8]
- show auto-terminate log also in AWS_EC2_CW mode

## [1.4.7]
- add AWS_EC2_CW to show cw tail command

## [1.4.6]
- enable awslogs on reboot
- improve message when auto-terminate gets called from a previous ami

## [1.4.5]
- fix cloudwatch python install for ubuntu

## [1.4.4]
- add AWS_EC2_REGION env to set the region for the cloudwatch log displayed url

## [1.4.3]
- fix get_region when aws-ec2 called from an ec2 instance

## [1.4.2]
- fix cloudwatch for ubuntu

## [1.4.1]
- fix cloudwatch support check and add add_to_clipboard url
- fix copy_to_clipboard
- remove normalize_os debugging call

## [1.4.0]
- Merge pull request #8 from tongueroo/cloudwatch
- cloudwatch support for amazonlinux2 and ubuntu

## [1.3.2]
- add noop mode for clean ami command

## [1.3.1]
- fix cleaning so it cleans out the oldest images

## [1.3.0]
- Merge pull request #7 from tongueroo/clean: aws-ec2 clean ami command

## [1.2.2]
- add render_me_pretty as gem instead of submodule

## [1.2.1]
- fix formatting after found ami with puts

## [1.2.0]
- Merge pull request #6 from tongueroo/wait: aws-ec2 wait ami command
- Fix dependencies: add aws-sdk-s3 dependency
- require render_me_pretty as vendor submodule for now

## [1.1.0]
- Merge pull request #5 from tongueroo/auto-terminate
- allow AWS_RDS_CODE_VERSION env variable
- restructure way scripts work for sanity
- bash scripts: ami_creation.sh and auto_terminate.sh
- support only amazonlinux2 and ubuntu

## [1.0.1]
- update ordering of the info displayed

## [1.0.0]
- Merge pull request #1 from tongueroo/cli-template-upgrade
- Merge pull request #2 from tongueroo/render_me_pretty
- Merge pull request #3 from tongueroo/s3-upload
- Merge pull request #4 from tongueroo/layout-support
- add --randomize option
- add extract_scripts and add_ssh_key helpers
- conventionally use name of server as profile if profile exists
- introduce settings.yml
- latest_ami: exit if image cannot be found

## [0.9.0]
- much improved error messaging
- rename docs folder
- update readme

## [0.8.4]
- add doc/example
- rename to commands to compile and upload
- rename to core_helper, only require specfic activesupport dependencies
- generate user-data in tmp/user-data.txt instead

## [0.8.3]
- change compile_keep to compile_clean option instead

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
