module AwsEc2
  module Util
    include TemplateHelper

    def pretty_display(data)
      data = data.deep_stringify_keys

      message = "base64-encoded: use aws-ec2 userdata command to view"
      # TODO: generalize this
      data["user_data"] = message if data["user_data"]
      data["spot_fleet_request_config"]["launch_specifications"].each do |spec|
        spec["user_data"] = message if spec["user_data"]
      end if data["spot_fleet_request_config"] && data["spot_fleet_request_config"]["launch_specifications"]

      puts YAML.dump(data)
    end

    def load_profiles(profile_name)
      return @profile_params if @profile_params

      profile_file = "#{root}/profiles/#{profile_name}.yml"
      base_path = File.dirname(profile_file)
      default_file = "#{base_path}/default.yml"

      params_exit_check!(profile_file, default_file)

      params = File.exist?(profile_file) ?
                  load_profile(profile_file) :
                  load_profile(default_file)
      @profile_params = params
    end

    def params_exit_check!(profile_file, default_file)
      return if File.exist?(profile_file) or File.exist?(default_file)

      puts "Unable to find a #{profile_file} or #{default_file} profile file."
      puts "Please double check."
      exit # EXIT HERE
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      puts "Using profile: #{file}"
      data = YAML.load(erb_result(file))
      data ? data : {} # in case the file is empty
      data.has_key?("run_instances") ? data["run_instances"] : data
    end

    def profile_name
      # allow user to specify the path also
      if @options[:profile] && File.exist?(@options[:profile])
        profile = File.basename(@options[:profile], '.yml')
      end

      # conventional profile is the name of the ec2 instance
      profile || @options[:profile] || @options[:name]
    end

    def root
      ENV['AWS_EC2_ROOT'] || '.'
    end
  end
end
