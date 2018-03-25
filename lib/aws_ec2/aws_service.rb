require 'aws-sdk-ec2'

module AwsEc2::AwsService
  def ec2
    @ec2 ||= Aws::EC2::Client.new
  end
end
