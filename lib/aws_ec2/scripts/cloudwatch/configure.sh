#!/bin/bash

if [ $# -eq 0 ]; then
  command=$(basename "$0")
  echo "Usage: $command LOG_GROUP_NAME"
  echo "Examples:"
  echo "  $command aws-ec2"
  echo "  $command ec2"
  exit 1
fi
LOG_GROUP_NAME=$1

# Inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/dmesg

[/var/log/messages]
file = /var/log/messages
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/messages
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/docker
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/ecs/audit.log
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/cloud-init.log]
file = /var/log/cloud-init.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/cloud-init.log
datetime_format =

[/var/log/cloud-init-output.log]
file = /var/log/cloud-init-output.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/cloud-init-output.log
datetime_format =

[/var/log/cfn-init.log]
file = /var/log/cfn-init.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/cfn-init.log
datetime_format =

[/var/log/cfn-hup.log]
file = /var/log/cfn-hup.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/cfn-hup.log
datetime_format =

[/var/log/cfn-wire.log]
file = /var/log/cfn-wire.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/cfn-wire.log
datetime_format =

[/var/log/secure]
file = /var/log/secure
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/secure
datetime_format =

[/var/log/audit/audit.log]
file = /var/log/audit/audit.log
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/audit/audit.log
datetime_format =

[/var/lib/cloud/instance/user-data.txt]
file = /var/lib/cloud/instance/user-data.txt
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/lib/cloud/instance/user-data.txt
datetime_format =

[/var/log/messages]
file = /var/log/messages
log_group_name = ${LOG_GROUP_NAME}
log_stream_name = {instance_id}/var/log/messages
datetime_format =

EOF

region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf
