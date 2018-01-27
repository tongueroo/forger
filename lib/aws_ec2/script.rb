module AwsEc2
  class Script
    def initialize(options={})
      @options = options
    end

    def auto_terminate
      load_template("auto_terminate.sh")
    end

    def create_ami
      # set some variables for the template
      @ami_name = @options[:ami]
      region = `aws configure get region`.strip rescue 'us-east-1'
      load_template("ami_creation.sh")
    end

  private
    def load_template(name)
      template = IO.read(File.expand_path("../scripts/#{name}", __FILE__))
      text = ERB.new(template, nil, "-").result(binding)
      "#" * 60 + "\n#{text}"
    end
  end
end
