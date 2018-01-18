module AwsEc2
  module Util
    def load_profiles(profile_name)
      profile_file = "#{root}/profiles/#{profile_name}.yml"
      base_path = File.dirname(profile_file)
      default_file = "#{base_path}/default.yml"

      params_exit_check!(profile_file, default_file)

      defaults = load_profile(default_file)
      params = load_profile(profile_file)
      params = defaults.merge(params)
    end

    def params_exit_check!(profile_file, default_file)
      return if File.exist?(profile_file) or File.exist?(default_file)

      puts "Unable to find a #{profile_file} or #{default_file} profile file."
      puts "Please double check."
      exit # EXIT HERE
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      puts "Using profile #{file}"
      data = YAML.load_file(file)
      data ? data : {} # in case the file is empty
    end

    def profile_name
      # allow user to specify the path also
      if File.exist?(@options[:profile])
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
