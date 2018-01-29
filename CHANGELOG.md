# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

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
