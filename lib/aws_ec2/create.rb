require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Create
    include AwsServices

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

    # params are main derived from the profile file
    def params
      params = defaults.merge({}) # load from profile
    end

    def params
      profile_file = "#{root}/profiles/#{profile_name}.yml"
      default_file = "#{root}/profiles/default.yml"
      if !File.exist?(profile_file) && !File.exist?(default_file)
        puts "Unable to find a #{profile_file} or #{default_file} profile file."
        puts "Please double check."
        exit
      end

      defaults = load_profile(default_file)
      params = load_profile(profile_file)
      params = defaults.merge(params)

      normalize_launch_template(params).deep_symbolize_keys
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      data = YAML.load_file(file)
      data ? data : {}
    end

    def profile_name
      # conventional profile is the name of the database
      @options[:profile] || @options[:name]
    end

    def root
      ENV['AWS_EC2_ROOT'] || '.'
    end
  end
end
