require 'yaml'

module AwsEc2
  class Config < Base
    def initialize(options={})
      super
      @path = options[:path] || "#{AwsEc2.root}/config/#{AwsEc2.env}.yml"
    end

    @@data = nil
    def data
      return @@data if @@data
      @@data = YAML.load_file(@path)
    rescue Errno::ENOENT => e
      puts e.message
      puts "The #{@path} does not exist. Please double check that it exists."
      exit
    end
  end
end
