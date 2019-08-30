module Forger
  class Script
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
      @region = 'us-east-1' if ENV['TEST']
      @region ||= `aws configure get region`.strip rescue 'us-east-1'
      load_template("ami_creation.sh")
    end

    def extract_forger_scripts
      load_template("extract_forger_scripts.sh")
    end

  private
    def load_template(name)
      template = IO.read(File.expand_path("script/templates/#{name}", File.dirname(__FILE__)))
      ERB.new(template, nil, "-").result(binding) # text
    end
  end
end
