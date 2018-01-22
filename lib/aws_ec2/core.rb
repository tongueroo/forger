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
      ENV['AWS_EC2_ROOT'] || '.'
    end
  end
end
