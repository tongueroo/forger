#!/bin/bash -exu

export HOME=/root # In user-data env USER=root but HOME is not set
cd ~ # user-data starts off in / so go to $HOME

<%= add_ssh_key %>

<%= extract_scripts(to: "/opt") %>

<%= yield %>

uptime | tee /var/log/boot-time.log
