class AwsEc2::Create
  class Params
    include AwsEc2::TemplateHelper

    def initialize(options)
      @options = options
    end

    # deep_symbolize_keys is ran at the very end only.
    # up until that point we're dealing with String keys.
    def generate
      cleanup
      params = load_profiles(profile_name)
      decorate_params(params)
      normalize_launch_template(params).deep_symbolize_keys
    end

    def decorate_params(params)
      upsert_name_tag!(params)
      replace_runtime_options!(params)
      params
    end

    # Expose a list of runtime params that are convenient. Try to limit the
    # number of options from the cli to keep tool simple. Most options can
    # be easily control through profile files. The runtime options that are
    # very convenient to have at the CLI are modified here.
    def replace_runtime_options!(params)
      params["image_id"] = @options[:source_ami_id] if @options[:source_ami_id]
      params
    end

    def cleanup
      FileUtils.rm_f("/tmp/aws-ec2/user-data.txt")
    end

    # Adds instance ec2 tag if not already provided
    def upsert_name_tag!(params)
      specs = params["tag_specifications"] || []

      # insert an empty spec placeholder if one not found
      spec = specs.find do |s|
        s["resource_type"] == "instance"
      end
      unless spec
        spec = {
            "resource_type" => "instance",
            "tags" => []
          }
        specs << spec
      end
      # guaranteed there's a tag_specifications with resource_type instance at this point

      tags = spec["tags"] || []

      unless tags.map { |t| t["key"] }.include?("Name")
        tags << { "key" => "Name", "value" => @options[:name] }
      end

      specs = specs.map do |s|
        # replace the name tag value
        if s["resource_type"] == "instance"
          {
            "resource_type" => "instance",
            "tags" => tags
          }
        else
          s
        end
      end

      params["tag_specifications"] = specs
      params
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

    def load_profiles(profile_name)
      return @profile_params if @profile_params

      profile_file = "#{AwsEc2.root}/profiles/#{profile_name}.yml"
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
  end
end
