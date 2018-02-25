module AwsEc2
  class Base
    def initialize(options={})
      @options = options.clone
      AwsEc2.validate_in_project!
    end
  end
end
