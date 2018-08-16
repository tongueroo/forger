#!/bin/bash -exu

cat > /etc/init/awslogs.conf <<- EOL
#upstart-job
description "Configure and start CloudWatch Logs agent on Amazon instance"
author "BoltOps"
start on runlevel [2345]

script
  exec 2>>/var/log/cloudwatch-logs-start.log
  set -x

  service awslogs start
  chkconfig awslogs on
end script
EOL
