require 'yaml'
require 'render_me_pretty'

module Forger
  class Variables < Base
    include Forger::Template

    def initialize(options={})
      super
      @path = options[:path] || "#{Forger.root}/config/variables/#{Forger.env}.yml"
    end

    @@data = nil
    def data
      return @@data if @@data

      text = RenderMePretty.result(@path, context: context)
      @@data = text.empty? ? {} : YAML.load(text)
      @@data = ActiveSupport::HashWithIndifferentAccess.new(@@data)
    rescue Errno::ENOENT => e
      puts e.message
      puts "The #{@path} does not exist. Please double check that it exists."
      exit
    end
  end
end
