cat > /etc/init/awslogs.conf <<- EOL
#upstart-job
description "Configure and start CloudWatch Logs agent EC2 instance"
author "Tung Nguyen"
start on startup

script
  exec 2>>/var/log/cloudwatch-logs-start.log
  set -x

  service awslogs start
  chkconfig awslogs on
end script
EOL

initctl list
initctl reload-configuration
initctl start awslogs
initctl list
