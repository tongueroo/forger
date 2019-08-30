require 'yaml'
require 'render_me_pretty'

module Forger
  class Config < Base
    include Forger::Template

    def initialize(options={})
      super
      @path = options[:path] || "#{Forger.root}/config/#{Forger.env}.yml"
    end

    @@data = nil
    def data
      return @@data if @@data

      text = RenderMePretty.result(@path, context: context)
      @@data = text.empty? ? {} : YAML.load(text)
    rescue Errno::ENOENT => e
      puts e.message
      puts "The #{@path} does not exist. Please double check that it exists."
      exit
    end
  end
end
