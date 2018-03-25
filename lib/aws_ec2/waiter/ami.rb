module AwsEc2::Waiter
  class Ami < AwsEc2::Base
    def wait
      puts "Waiting for @options[:name]} to be available..."
    end
  end
end
