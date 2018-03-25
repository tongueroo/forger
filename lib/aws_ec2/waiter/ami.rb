module AwsEc2::Waiter
  class Ami < AwsEc2::Base
    include AwsService

    def wait
      puts "Waiting for @options[:name]} to be available..."
    end
  end
end
