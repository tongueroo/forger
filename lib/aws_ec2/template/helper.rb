require "active_support/core_ext/string"

module AwsEc2::Template
  module Helper
    def autoinclude(klass)
      autoload klass, "aws_ec2/template/helper/#{klass.to_s.underscore}"
      include const_get(klass)
    end
    extend self

    autoinclude :AmiHelper
    autoinclude :CoreHelper
    autoinclude :PartialHelper
  end
end
