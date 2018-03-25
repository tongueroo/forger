Examples:

    $ aws-ec2 upload

Compiles the app/scripts and app/user-data files to the tmp folder. Then uploads the files to an s3 bucket that is configured in config/settings.yml.  Example s3_folder setting:

```yaml
development:
  s3_folder: my-bucket/folder # enables auto sync to s3
```
