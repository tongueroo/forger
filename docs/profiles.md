# Profiles

## Overview

The `profiles` files are YAML files that set the parameters passed to the `ec2.run_instances` API call.  Example:

`profiles/box.yml`:

```yaml
---
image_id: ami-97785bed
instance_type: t2.medium
key_name: default
max_count: 1
min_count: 1
security_group_ids: <%= @security_group_ids %>
subnet_id: <%= @subnets.shuffle.first %>
user_data: "<%= user_data("bootstrap") %>"
iam_instance_profile:
  name: IAMProfileName
```

The forger call to create the ec2 instance would be:

    forger create box

## Base Profile

If you have multiple profiles with a common base, you can create a `profiles/base.yml` file which will have the shared settings.  Example structure:

    profiles
    ├── base.yml
    ├── box.yml
    └── test.yml

The `base.yml` gets merged with `box.yml`.
The `base.yml` also gets merged with `test.yml`.

## Profile Conventions

By convention the profile file will be same as the name to you pass to the the `forger create NAME`.  So

    forger create box

Automatically matches to the `profiles/box.yml`.  If you need to override the convention you can use the `--profile` option.  Example:

    forger create box-2 --profile box
