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
      puts user_data(@options[:name], false)
    end
  end
end
