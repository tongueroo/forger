#!/bin/bash -eux
function schedule_termination() {
  chmod +x /etc/rc.local
  sed -i 's/exit 0//' /etc/rc.local
  echo "/opt/aws-ec2/auto_terminate.sh after_ami >> /var/log/auto-terminate.log 2>&1" >> /etc/rc.local
}

function unschedule_termination() {
  grep -v terminate-myself /etc/rc.local > /etc/rc.local.tmp
  mv /etc/rc.local{.tmp,}
}
