require 'pathname'

module AwsEc2
  module Core
    @@config = nil
    def config
      @@config ||= Config.new.settings
    end

    def env
      ENV['AWS_EC2_ENV'] || 'development'
    end

    def root
      path = ENV['AWS_EC2_ROOT'] || '.'
      Pathname.new(path)
    end
  end
end
