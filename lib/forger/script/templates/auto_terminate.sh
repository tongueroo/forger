#!/bin/bash

set -e

/opt/forger/auto_terminate/setup.sh

<% if @options[:auto_terminate] -%>
  <% if @options[:ami_name] %>
/opt/forger/auto_terminate.sh later
  <% else %>
/opt/forger/auto_terminate.sh now # terminate immediately
  <% end -%>
<% end -%>

set +e
