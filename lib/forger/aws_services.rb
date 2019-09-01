require 'aws-sdk-cloudformation'
require 'aws-sdk-ec2'
require 'aws-sdk-s3'

module Forger::AwsServices
  extend Memoist

  def cfn
    Aws::CloudFormation::Client.new
  end
  memoize :cfn

  def ec2
    Aws::EC2::Client.new
  end
  memoize :ec2

  def s3
    Aws::S3::Client.new
  end
  memoize :s3
end
