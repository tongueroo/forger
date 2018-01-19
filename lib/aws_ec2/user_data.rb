require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class UserData
    include TemplateHelper
    include Util

    def initialize(options)
      @options = options
    end

    def run
      if File.exist?(@options[:name])
        filename = File.basename(@options[:name], '.sh')
      end

      filename ||= @options[:name]
      path = "profiles/user-data/#{filename}.sh"
      puts erb_result(path)
    end
  end
end
