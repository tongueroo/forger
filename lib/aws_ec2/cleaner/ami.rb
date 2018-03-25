module AwsEc2::Cleaner
  class Ami < AwsEc2::Base
    include AwsEc2::AwsService

    def clean
      puts "Cleaning out old AMIs..."
    end
  end
end
