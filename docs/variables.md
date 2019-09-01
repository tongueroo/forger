# Variables

## Overview

You can create variables that are accessible in the `app/scripts` and `profiles` files.  You define the variables in the `config/variables/FORGER_ENV.rb` files.

## Structure

    config
    └── variables
        ├── base.rb
        ├── development.rb
        └── production.rb

## Variable Definitions

Examples of variables definitions:

config/variables/base.rb:

```ruby
@keypair = "my-keypair-1"
```

config/variables/development.rb:

```ruby
---
instance_type: t2.medium
key_name: default
max_count: 1
min_count: 1
security_group_ids: <%= @security_group_ids %>
subnet_id: <%= @subnets.shuffle.first %>
iam_instance_profile:
  name: IAMProfileName
```

## Variables Layering

The variable files are layered together.  The base.rb variable file always get evaulated. Then environment specific variables get evaluated according to the `FORGER_ENV` value. For example, `FORGER_ENV=development` results in `config/variables/development.rb` getting used.

## Accessing Variables

You access the variables files with ERB. Example:

profiles/server.yml:

```yaml
---
security_group_ids: <%= @security_group_ids %>
subnet_id: <%= @subnets.shuffle.first %>
```
