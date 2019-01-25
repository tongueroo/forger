require 'pathname'
require 'yaml'

module Forger
  module Core
    @@config = nil
    def config
      @@config ||= Config.new.data
    end

    def settings
      Setting.new.data
    end

    # cloudwatch cli option takes higher precedence than when its set in the
    # config/settings.yml file.
    def cloudwatch_enabled?(options)
      !options[:cloudwatch].nil? ?
        options[:cloudwatch] : # options can use symbols because this the options hash from Thor
        settings["cloudwatch"] # settings uses strings as keys
    end

    def root
      path = ENV['FORGER_ROOT'] || '.'
      Pathname.new(path)
    end

    def validate_in_project!
      unless File.exist?("#{root}/profiles")
        puts "Could not find a profiles folder in the current directory.  It does not look like you are running this command within a forger project.  Please confirm that you are in a forger project and try again.".color(:red)
        exit
      end
    end

    @@env = nil
    def env
      return @@env if @@env
      env = env_from_profile(ENV['AWS_PROFILE']) || 'development'
      env = ENV['FORGER_ENV'] if ENV['FORGER_ENV'] # highest precedence
      @@env = env
    end

    def build_root
      Base::BUILD_ROOT
    end

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Forger.env from within settings class.
    def env_from_profile(aws_profile)
      settings_path = "#{Forger.root}/config/settings.yml"
      return unless File.exist?(settings_path)

      data = YAML.load_file(settings_path)
      env = data.find do |_env, setting|
        setting ||= {}
        profiles = setting['aws_profiles']
        profiles && profiles.include?(aws_profile)
      end
      env.first if env
    end
  end
end
