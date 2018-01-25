$:.unshift(File.expand_path("../", __FILE__))
require "aws_ec2/version"
require "colorize"

module AwsEc2
  autoload :Help, "aws_ec2/help"
  autoload :Command, "aws_ec2/command"
  autoload :CLI, "aws_ec2/cli"
  autoload :AwsServices, "aws_ec2/aws_services"
  autoload :Util, "aws_ec2/util"
  autoload :Create, "aws_ec2/create"
  autoload :Spot, "aws_ec2/spot"
  autoload :TemplateHelper, "aws_ec2/template_helper"
  autoload :UserData, "aws_ec2/user_data"
  autoload :Ami, "aws_ec2/ami"
  autoload :Config, "aws_ec2/config"
  autoload :Core, "aws_ec2/core"
  autoload :Dotenv, "aws_ec2/dotenv"
  autoload :Hook, "aws_ec2/hook"

  extend Core
end

AwsEc2::Dotenv.load!
