require 'yaml'

module AwsEc2
  class Setting
    def initialize(check_project=true)
      @check_project = check_project
    end

    # data contains the settings.yml config.  The order or precedence for settings
    # is the project lono/settings.yml and then the ~/.lono/settings.yml.
    @@data = nil
    def data
      return @@data if @@data

      if @check_project && !File.exist?(project_settings_path)
        puts "ERROR: No settings file at #{project_settings_path}.  Are you sure you are in a aws-ec2 project?".colorize(:red)
        exit 1
      end

      all_envs = load_file(project_settings_path)
      all_envs = merge_base(all_envs)
      @@data = all_envs[AwsEc2.env] || all_envs["base"] || {}
    end

  private
    def load_file(path)
      return Hash.new({}) unless File.exist?(path)

      content = RenderMePretty.result(path)
      data = YAML.load(content)
      # If key is is accidentally set to nil it screws up the merge_base later.
      # So ensure that all keys with nil value are set to {}
      data.each do |env, _setting|
        data[env] ||= {}
      end
      data
    end

    # automatically add base settings to the rest of the environments
    def merge_base(all_envs)
      base = all_envs["base"] || {}
      all_envs.each do |env, settings|
        all_envs[env] = base.merge(settings) unless env == "base"
      end
      all_envs
    end

    def project_settings_path
      "#{AwsEc2.root}/config/settings.yml"
    end
  end
end
