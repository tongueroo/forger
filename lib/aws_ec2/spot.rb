require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Spot
    include AwsServices
    include Util

    def initialize(options)
      @options = options
    end

    def run
      puts "Creating spot instance fleet request..."
      display_info
      if @options[:noop]
        puts "NOOP mode enabled. spot instance fleet request not created."
        return
      end

      resp = ec2.request_spot_fleet(params)
      puts "Spot instance fleet request created"
    end

    # params are main derived from profile files
    def params
      params = load_profiles("spot/#{profile_name}")
      params = decorate_launch_template_configs(params)
      params.deep_symbolize_keys
    end

    # Decorates the launch_template_configs:
    #
    #   * Ensure that a launch template version is set
    #   * Sets the ec2 tag name
    def decorate_launch_template_configs(params)
      launch_template_configs = params["spot_fleet_request_config"]["launch_template_configs"]
      return params unless launch_template_configs

      # Assume only one launch_template_configs
      # TODO: add support for multiple launch_template_configs
      config = launch_template_configs.first
      spec = config["launch_template_specification"]
      version = spec["version"]
      unless version
        latest_version = latest_version(spec["launch_template_name"])
      end

      config["launch_template_specification"]["version"] ||= latest_version

      # TODO: figure out how to override a tag for a launch template
      # # Sets the EC2 tag name.
      # # Replace all tag_specifications for simplicity.
      # tag_specifications = [{
      #     resource_type: "instance",
      #     tags: [{ key: "Name", value: @options[:name] }],
      #   }]
      # config["overrides"] << ["tag_specifications"] << tag_specifications

      # replace all configs
      params["spot_fleet_request_config"]["launch_template_configs"] = [config]

      params
    end

    def latest_version(launch_template_name)
      resp = ec2.describe_launch_template_versions(launch_template_name: launch_template_name)
      version = resp.launch_template_versions.first
      version.version_number.to_s # request_spot_fleet expects this to be a String
    rescue Aws::EC2::Errors::InvalidLaunchTemplateNameNotFoundException => e
      puts e.message
      puts "Please double check that the launch template exists"
      exit
    end

    def display_info
      puts "Using the following parameters:"
      pretty_display(params)
    end
  end
end
