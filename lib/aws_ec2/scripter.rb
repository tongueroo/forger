module AwsEc2
  class Scripter
    autoload :Compile, "aws_ec2/scripter/compile"
    autoload :Compress, "aws_ec2/scripter/compress"
    autoload :Upload, "aws_ec2/scripter/upload"

    def initialize(options={})
      @options = options
    end

    def auto_terminate
      @ami_name = @options[:ami_name]
      load_template("auto_terminate.sh")
    end

    def create_ami
      # set some variables for the template
      @ami_name = @options[:ami_name]
      @region = `aws configure get region`.strip rescue 'us-east-1'
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
