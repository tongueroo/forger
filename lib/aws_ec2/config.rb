require 'yaml'

module AwsEc2
  class Config
    def initialize(path="#{AwsEc2.root}/config/#{AwsEc2.env}.yml")
      @path = path
    end

    def settings
      YAML.load_file(@path)
    rescue Errno::ENOENT => e
      puts e.message
      puts "The #{@path} does not exist. Please double check that it exists."
      exit
    end
  end
end
