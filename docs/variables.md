# Variables

## Overview

You can create variables that are accessible in the `app/scripts` and `profiles` files.  You define the variables in the `config/variables/FORGER_ENV.yml` files.

## Structure

    config
    └── variables
        ├── development.yml
        └── production.yml

## Accessing Variables

You use the `vars` helper method to access the variables.  You can also use the longer `variables` method.  Example:

profiles/server.yml:


<%= vars[:subnets] %>
