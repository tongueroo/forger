require "active_support" # for autoload
require "active_support/core_ext/string"

module AwsEc2
  module TemplateHelper
    # auto load all the template_helpers
    template_helper_path = File.expand_path("../template_helper", __FILE__)
    Dir.glob("#{template_helper_path}/*").each do |path|
      next if File.directory?(path)
      filename = File.basename(path, '.rb')
      class_name = filename.classify
      instance_eval do
        autoload class_name.to_sym, "aws_ec2/template_helper/#{filename}"
        include const_get(class_name)
      end
    end
  end
end
