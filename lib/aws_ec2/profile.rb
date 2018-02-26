module AwsEc2
  class Profile
    include AwsEc2::Template

    def initialize(options)
      @options = options
    end

    def load
      return @profile_params if @profile_params

      check!

      file = profile_file(profile_name)
      @profile_params = load_profile(file)
    end

    def check!
      file = profile_file(profile_name)
      return if File.exist?(file)

      puts "Unable to find a #{file.colorize(:green)} profile file."
      puts "Please double check that it exists or that you specified the right profile.".colorize(:red)
      exit 1
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      puts "Using profile: #{file}".colorize(:green)
      text = RenderMePretty.result(file, context: context)
      data = YAML.load(text)
      data ? data : {} # in case the file is empty
      data.has_key?("run_instances") ? data["run_instances"] : data
    end

    # Determines a valid profile_name. Falls back to default
    def profile_name
      # allow user to specify the path also
      if @options[:profile] && File.exist?(@options[:profile])
        filename_profile = File.basename(@options[:profile], '.yml')
      end

      name = derandomize(@options[:name])
      if File.exist?(profile_file(name))
        name_profile = name
      end

      filename_profile ||
      @options[:profile] ||
      name_profile || # conventional profile is the name of the ec2 instance
      "default"
    end

    def profile_file(name)
      "#{AwsEc2.root}/profiles/#{name}.yml"
    end

    # Strip the random string at end of the ec2 instance name
    def derandomize(name)
      if @options[:randomize]
        name.sub(/-(\w{3})$/,'') # strip the random part at the end
      else
        name
      end
    end

  end
end
