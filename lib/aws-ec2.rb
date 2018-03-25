$:.unshift(File.expand_path("../", __FILE__))
require "aws_ec2/version"
require "colorize"
require "render_me_pretty"

module AwsEc2
  autoload :Help, "aws_ec2/help"
  autoload :Command, "aws_ec2/command"
  autoload :CLI, "aws_ec2/cli"
  autoload :AwsService, "aws_ec2/aws_service"
  autoload :Profile, "aws_ec2/profile"
  autoload :Base, "aws_ec2/base"
  autoload :Create, "aws_ec2/create"
  autoload :Ami, "aws_ec2/ami"
  autoload :Wait, "aws_ec2/wait"
  autoload :Clean, "aws_ec2/clean"
  autoload :Template, "aws_ec2/template"
  autoload :Script, "aws_ec2/script"
  autoload :Config, "aws_ec2/config"
  autoload :Core, "aws_ec2/core"
  autoload :Dotenv, "aws_ec2/dotenv"
  autoload :Hook, "aws_ec2/hook"
  autoload :Completion, "aws_ec2/completion"
  autoload :Completer, "aws_ec2/completer"
  autoload :Setting, "aws_ec2/setting"
  extend Core
end

AwsEc2::Dotenv.load!
