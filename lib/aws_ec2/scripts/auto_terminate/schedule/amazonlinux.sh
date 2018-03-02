#!/bin/bash -eux
function schedule_termination() {
  chmod +x /etc/rc.d/rc.local
  echo "/opt/aws-ec2/auto_terminate.sh now >> /var/log/auto-terminate.log 2>&1" >> /etc/rc.d/rc.local
}

function unschedule_termination() {
  grep -v terminate-myself /etc/rc.d/rc.local > /etc/rc.d/rc.local.tmp
  mv /etc/rc.d/rc.local.tmp /etc/rc.d/rc.local
}
