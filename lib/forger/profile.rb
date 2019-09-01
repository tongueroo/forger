module Forger
  class Profile < Base
    include Forger::Template

    def load
      return @profile_params if @profile_params

      check!

      file = profile_file(profile_name)
      @profile_params = load_profile(file)
    end

    def check!
      file = profile_file(profile_name)
      return if File.exist?(file)

      puts "Unable to find a #{file.color(:green)} profile file."
      puts "Please double check that it exists or that you specified the right profile.".color(:red)
      exit 1
    end

    def load_profile(file)
      return {} unless File.exist?(file)

      base_file, base_data = profile_file(:base), {}
      if File.exist?(base_file)
        puts "Detected profiles/base.yml"
        base_data = yaml_load(base_file)
      end

      puts "Using profile: #{file}".color(:green)
      data = yaml_load(file)
      data = base_data.merge(data)
      data.has_key?("run_instances") ? data["run_instances"] : data
    end

    def yaml_load(file)
      text = RenderMePretty.result(file, context: context)
      begin
        data = YAML.load(text) # data
        data ? data : {} # in case the file is empty
      rescue Psych::SyntaxError => e
        tmp_file = file.sub("profiles", Forger.build_root)
        FileUtils.mkdir_p(File.dirname(tmp_file))
        IO.write(tmp_file, text)
        puts "There was an error evaluating in your yaml file #{file}".color(:red)
        puts "The evaludated yaml file has been saved at #{tmp_file} for debugging."
        puts "ERROR: #{e.message}"
        exit 1
      end
    end


    # Determines a valid profile_name. Falls back to default
    def profile_name
      # allow user to specify the path also
      if @options[:profile] && File.exist?(@options[:profile])
        filename_profile = File.basename(@options[:profile], '.yml')
      end

      name = derandomize(@name)
      if File.exist?(profile_file(name))
        name_profile = name
      end

      filename_profile ||
      @options[:profile] ||
      name_profile || # conventional profile is the name of the ec2 instance
      "default"
    end

    def profile_file(name)
      "#{Forger.root}/profiles/#{name}.yml"
    end
  end
end
