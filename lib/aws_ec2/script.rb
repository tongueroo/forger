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

    def setup_scripts
      load_template("setup_scripts.sh")
    end

  private
    def prepend_scripts(user_data)
      text = ''
      text += script.cloudwatch if @options[:cloudwatch]
      text + user_data
    end

    def append_scripts(user_data)
      # assuming user-data script is a bash script for simplicity for now
      script = AwsEc2::Script.new(@options)
      requires_setup = @options[:auto_terminate] || @options[:ami_name]
      user_data += script.setup_scripts if requires_setup
      user_data += script.auto_terminate if @options[:auto_terminate]
      user_data += script.create_ami if @options[:ami_name]
      user_data
    end

    def load_template(name)
      template = IO.read(File.expand_path("script/templates/#{name}", File.dirname(__FILE__)))
      text = ERB.new(template, nil, "-").result(binding)
      "#" * 60 + "\n#{text}"
    end
  end
end
