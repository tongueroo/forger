#!/bin/bash
function schedule_termination() {
  chmod +x /etc/rc.d/rc.local
  echo "/opt/forger/auto_terminate.sh after_ami >> /var/log/auto-terminate.log 2>&1" >> /etc/rc.d/rc.local
}

function unschedule_termination() {
  grep -v auto_terminate.sh /etc/rc.d/rc.local > /etc/rc.d/rc.local.tmp
  mv /etc/rc.d/rc.local.tmp /etc/rc.d/rc.local
}
