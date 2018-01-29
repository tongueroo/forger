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

    def validate_in_project!
      unless File.exist?("#{root}/profiles")
        puts "Could not find a profiles folder in the current directory.  It does not look like you are running this command within a aws-ec2 project.  Please confirm that you are in a aws-ec2 project and try again.".colorize(:red)
        exit
      end
    end
  end
end
