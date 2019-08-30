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
@subnets = %w[subnet-111 subnet-222]
```

## Variables Layering

The variable files are layered together.  The base.rb variable file always get evaulated. Then environment specific variables get evaluated according to the `FORGER_ENV` value. For example, `FORGER_ENV=development` results in `config/variables/development.rb` getting used.

## Accessing Variables

You access the variables files with ERB. Example:

profiles/server.yml:

<%= @subnets %>
