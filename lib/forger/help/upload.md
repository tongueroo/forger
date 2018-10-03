Examples:

    $ forger upload

Compiles the app/scripts and app/user_data files to the tmp folder. Then uploads the files to an s3 bucket that is configured in config/settings.yml.  Example s3_folder setting:

```yaml
development:
  # Format 1: Simple String
  s3_folder: my-bucket/folder # enables auto sync to s3

  # Format 2: Hash
  # s3_folder:
  #   default: mybucket/path/to/folder
  #   dev_profile1: mybucket/path/to/folder
  #   dev_profile1: another-bucket/storage/path
```
