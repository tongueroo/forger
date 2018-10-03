# setup: shared functions, path, awscli, etc
source /opt/scripts/shared/functions.sh
export PATH=/usr/local/bin/:$PATH
configure_aws_cli /root
configure_aws_cli /home/ec2-user

# install software
/opt/scripts/install/common.sh

<%= personalize_script %>
