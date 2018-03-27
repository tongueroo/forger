#/bin/bash -exu

# The awslogs-agent-setup.py setup creates a systemd unit is called awslogs.
systemctl daemon-reload
systemctl restart awslogs
systemctl enable awslogs
# systemctl status awslogs
# systemctl is-enabled awslogs
