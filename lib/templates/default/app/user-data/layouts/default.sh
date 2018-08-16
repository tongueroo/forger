#!/bin/bash -exu

export HOME=/root # In user-data env USER=root but HOME is not set
cd ~ # user-data starts off in / so go to $HOME

<%= add_ssh_key %>

<%= extract_scripts(to: "/opt") %>

# setup: shared functions, path, awscli, etc
# The extract_scripts helper above extracts out the app/scripts files to /opt/scripts.
source /opt/scripts/shared/functions.sh
export PATH=/usr/local/bin/:$PATH
configure_aws_cli /root
configure_aws_cli /home/ec2-user

# install software
/opt/scripts/install/common.sh

<%= yield %>

# personalize_script is an example helper in app/helpers/application_helper.rb
<%= personalize_script %>

uptime | tee /var/log/boot-time.log
