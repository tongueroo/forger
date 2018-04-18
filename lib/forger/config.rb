require 'yaml'

module Forger
  class Config < Base
    def initialize(options={})
      super
      @path = options[:path] || "#{Forger.root}/config/#{Forger.env}.yml"
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
