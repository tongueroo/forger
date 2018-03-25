module AwsEc2::Waiter
  class Ami < AwsEc2::Base
    include AwsEc2::AwsService

    def wait
      delay = 30
      timeout = @options[:timeout]
      max_attempts = timeout / delay
      current_time = 0

      puts "Waiting for #{@options[:name]} to be available. Delay: #{delay}s. Timeout: #{timeout}s"
      return if ENV['TEST']

      # Using while loop because of issues with ruby's Timeout module
      # http://www.mikeperham.com/2015/05/08/timeout-rubys-most-dangerous-api/
      detected = detect_ami
      until detected || current_time > timeout
        print '.'
        sleep delay
        current_time += 30
        detected = detect_ami
      end

      if current_time > timeout
        puts "ERROR: Timeout. Unable to detect and available ami: #{@options[:name]}"
        exit 1
      else
        puts "Found available ami #{@options[:name]}"
      end
      puts
    end

  private
    # Using custom detect_ami instead of ec2.wait_until(:image_availalbe, ...)
    # because we start checking for the ami even before we've called
    # create_ami.  We start checking right after we launch the instance
    # which will create the ami at the end.
    def detect_ami(owners=["self"])
      images = ec2.describe_images(
        owners: owners,
        filters: filters
      ).images
      pp images
      detected = images.first
      !!detected
    end

    def filters
      name_is_ami_id = @options[:name] =~ /^ami-/

      filters = [{name: "state", values: ["available"]}]
      filters << if name_is_ami_id
          {name: "image-id", values: [@options[:name]]}
        else
          {name: "name", values: [@options[:name]]}
        end

      filters
    end
  end
end
