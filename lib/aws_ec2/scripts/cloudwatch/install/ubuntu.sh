#!/bin/bash -eux

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html

REGION=$(curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')

type python || apt-get install -y python-pip

# Install awslogs and the jq JSON parser
curl -s https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O

# in order to install awslogs non-interactively we need a filler configfile
mkdir -p /etc/awslogs
cat > /etc/awslogs/awslogs.conf <<- EOL
[general]
state_file = /var/awslogs/state/agent-state
## filler config file, will get replaced by configure.sh script
EOL

python ./awslogs-agent-setup.py --region "$REGION" --non-interactive --configfile=/etc/awslogs/awslogs.conf
