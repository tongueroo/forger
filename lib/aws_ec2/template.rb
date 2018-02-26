require "active_support" # for autoload
require "active_support/core_ext/string"

module AwsEc2
  module Template
    autoload :Context, "aws_ec2/template/context"
    autoload :Helper, "aws_ec2/template/helper"

    def context
      @context ||= AwsEc2::Template::Context.new(@options)
    end
  end
end
