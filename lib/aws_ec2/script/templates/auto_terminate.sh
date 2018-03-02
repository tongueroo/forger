#!/bin/bash -eux

/opt/aws-ec2/auto_terminate/setup.sh

<% if @options[:auto_terminate] -%>
  <% if @options[:ami_name] %>
/opt/aws-ec2/auto_terminate.sh later
  <% else %>
/opt/aws-ec2/auto_terminate.sh now # terminate immediately
  <% end -%>
<% end -%>
