module AwsEc2
  class Base
    def initialize(options={})
      @options = options.clone
      AwsEc2.validate_in_project!
      Profile.new(@options).check!
    end
  end
end
