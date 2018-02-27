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
      @@data = all_envs[AwsEc2.env]
    end

  private
    def load_file(path)
      return Hash.new({}) unless File.exist?(path)

      content = RenderMePretty.result(path)
      data = YAML.load(content)
      # ensure no nil values
      data.each do |key, value|
        data[key] = {} if value.nil?
      end
      data
    end

    def project_settings_path
      "#{AwsEc2.root}/config/settings.yml"
    end
  end
end
