#/bin/bash -exu

# Interestingly, the awslogs-agent-setup.py command in the install.sh script
# already sets up systemd.
# With the yum awslogs-agent-setup.py setup, the systemd is called awslogs

# We just have to reload and restart it since we reconfigured it
systemctl daemon-reload
systemctl restart awslogs
# systemctl status awslogs
