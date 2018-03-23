module AwsEc2
  class Script
    autoload :Compile, "aws_ec2/script/compile"
    autoload :Compress, "aws_ec2/script/compress"
    autoload :Upload, "aws_ec2/script/upload"

    def initialize(options={})
      @options = options
    end

    def add_to_user_data!(user_data)
      user_data
    end

    def auto_terminate_after_timeout
      load_template("auto_terminate_after_timeout.sh")
    end

    def auto_terminate
      # set variables for the template
      @ami_name = @options[:ami_name]
      load_template("auto_terminate.sh")
    end

    def cloudwatch
      load_template("cloudwatch.sh")
    end

    def create_ami
      # set variables for the template
      @ami_name = @options[:ami_name]
      @region = `aws configure get region`.strip rescue 'us-east-1'
      load_template("ami_creation.sh")
    end

    def extract_aws_ec2_scripts
      load_template("extract_aws_ec2_scripts.sh")
    end

  private
    def load_template(name)
      template = IO.read(File.expand_path("script/templates/#{name}", File.dirname(__FILE__)))
      text = ERB.new(template, nil, "-").result(binding)
    end
  end
end
