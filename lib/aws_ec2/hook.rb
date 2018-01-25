require 'yaml'

module AwsEc2
  class Hook
    def initialize(options={})
      @options = options
    end

    def run(name)
      return unless hooks[name]
      command = hooks[name]
      puts "Running hook #{name}: #{command}"
      sh(command)
    end

    def hooks
      hooks_path = "#{AwsEc2.root}/config/hooks.yml"
      data = File.exist?(hooks_path) ? YAML.load_file(hooks_path) : {}
      data ? data : {} # in case the file is empty
    end

    def sh(command)
      puts "=> #{command}".colorize(:cyan)
      system(command)
    end

    def self.run(name)
      Hook.new.run(name.to_s)
    end
  end
end
