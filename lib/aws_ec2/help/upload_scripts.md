Examples:

  $ aws-ec2 upload_scripts

Compiles the app/scripts and app/user-data files to the tmp folder. Then uploads the files to an s3 bucket that is configured in config/[AWS_EC2_ENV].yml.  Example scripts_s3_bucket config:

```yaml
scripts_s3_bucket: my-bucket # enables auto sync to s3
```
