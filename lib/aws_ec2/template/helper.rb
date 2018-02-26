module AwsEc2::Template
  module Helper
    # TODO: add method to remove duplication
    autoload :AmiHelper, "aws_ec2/template/helper/ami_helper"
    autoload :CoreHelper, "aws_ec2/template/helper/core_helper"
    autoload :PartialHelper, "aws_ec2/template/helper/partial_helper"
    include AmiHelper
    include CoreHelper
    include PartialHelper
  end
end
