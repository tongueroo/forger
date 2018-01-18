require 'yaml'
require 'active_support/core_ext/hash'

module AwsEc2
  class Spot
    include AwsServices
    include Util

    def initialize(options)
      @options = options
    end

    def run
      puts "Creating spot instance fleet request..."
      display_info
      if @options[:noop]
        puts "NOOP mode enabled. spot instance fleet request not created."
        return
      end

      resp = ec2.request_spot_fleet(params)
      puts "Spot instance fleet request created"
    end

    # params are main derived from profile files
    def params
      load_profiles("spot/#{profile_name}")
    end

    def display_info
      puts "Using the following parameters:"
      pp params
    end
  end
end
