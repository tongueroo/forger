require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Create
    include AwsServices
    include Util

    def initialize(options)
      @options = options
    end

    def run
      puts "Creating EC2 instance #{@options[:name]}..."
      display_info
      if @options[:noop]
        puts "NOOP mode enabled. EC2 instance not created."
        return
      end

      resp = ec2.run_instances(params)
      puts "EC2 instance #{@options[:name]} created! 🎉"
      puts "Visit https://console.aws.amazon.com/ec2/home to check on the status"
    end

    # params are main derived from profile files
    def params
      params = load_profiles(profile_name)
      normalize_launch_template(params).deep_symbolize_keys
    end

    # Allow adding launch template as a simple string.
    #
    # Standard structure:
    # {
    #   launch_template: { launch_template_name: "TestLaunchTemplate" },
    # }
    #
    # Simple string:
    # {
    #   launch_template: "TestLaunchTemplate",
    # }
    #
    # When launch_template is a simple String it will get transformed to the
    # standard structure.
    def normalize_launch_template(params)
      if params["launch_template"].is_a?(String)
        launch_template_identifier = params["launch_template"]
        launch_template = if launch_template_identifier =~ /^lt-/
            { "launch_template_id" => launch_template_identifier }
          else
            { "launch_template_name" => launch_template_identifier }
          end
        params["launch_template"] = launch_template
      end
      params
    end

    # Hard coded sensible defaults.
    # Can be overridden easily with profiles
    def defaults
      {
        max_count: 1,
        min_count: 1,
      }
    end

    def display_info
      puts "Using the following parameters:"
      pp params

      display_launch_template
    end

    def display_launch_template
      launch_template = params[:launch_template]
      return unless launch_template

      resp = ec2.describe_launch_template_versions(
        launch_template_id: launch_template[:launch_template_id],
        launch_template_name: launch_template[:launch_template_name],
      )
      versions = resp.launch_template_versions
      launch_template_data = {} # combined launch_template_data
      versions.sort_by { |v| v[:version_number] }.each do |v|
        launch_template_data.merge!(v[:launch_template_data])
      end
      puts "launch template data (versions combined):"
      pp launch_template_data
    rescue Aws::EC2::Errors::InvalidLaunchTemplateNameNotFoundException => e
      puts "ERROR: The specified launched template #{launch_template.inspect} was not found."
      puts "Please double check that it exists."
      exit
    end
  end
end
