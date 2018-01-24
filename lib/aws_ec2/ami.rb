module AwsEc2
  class Ami
    def initialize(ami_name)
      @ami_name = ami_name
    end

    def user_data_snippet
      region = `aws configure get region`.strip rescue 'us-east-1'
      # the shebang line is here in case there's currently an
      # empty user-data script.  If there is not, then it wont hurt.
      template = IO.read(File.expand_path("../scripts/ami_creation.sh", __FILE__))
      ERB.new(template, nil, "-").result(binding)
    end
  end
end
