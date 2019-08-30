require 'pathname'
require 'yaml'

module Forger
  module Core
    extend Memoist

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

    # Overrides AWS_PROFILE based on the Forger.env if set in config/settings.yml
    # 2-way binding.
    def set_aws_profile!
      return if ENV['TEST']
      return unless File.exist?("#{Forger.root}/config/settings.yml") # for rake docs
      return unless settings # Only load if within Ufo project and there's a settings.yml
      data = settings[Forger.env] || {}
      if data["aws_profile"]
        puts "Using AWS_PROFILE=#{data["aws_profile"]} from FORGER_ENV=#{Forger.env} in config/settings.yml"
        ENV['AWS_PROFILE'] = data["aws_profile"]
      end
    end

    # Do not use the Setting#data to load the profile because it can cause an
    # infinite loop then if we decide to use Forger.env from within settings class.
    def settings
      path = "#{Forger.root}/config/settings.yml"
      return {} unless File.exist?(path)
      YAML.load_file(path)
    end
    memoize :settings

    private
    # Do not use the Setting class to load the profile because it can cause an
    # infinite loop then if we decide to use Forger.env from within settings class.
    def env_from_profile(aws_profile)
      return unless settings
      env = settings.find do |_env, settings|
        settings ||= {}
        profiles = settings['aws_profile']
        profiles && profiles == aws_profile
      end
      env.first if env
    end
  end
end
