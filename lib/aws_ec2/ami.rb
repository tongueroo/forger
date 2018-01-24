module AwsEc2
  class Ami
    def initialize(ami_name)
      @ami_name = ami_name
    end

    def user_data_snippet
      <<-EOL
#!/bin/bash -exu

# Create AMI Bundle
AMI_NAME="#{@ami_name}"
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 create-image --name $AMI_NAME --instance-id $INSTANCE_ID
EOL
    end
  end
end

