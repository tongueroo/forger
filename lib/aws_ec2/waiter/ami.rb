module AwsEc2::Waiter
  class Ami < AwsEc2::Base
    include AwsEc2::AwsService

    def wait
      puts "Waiting for #{@options[:name]} to be available..."

      begin
        puts "waiting"
        pp params
        ec2.wait_until(:image_available, params, {
          max_attempts: 5,
          # before_attempt: -> (attempts, response) do
          #   print '.'
          # end
        })
        puts

      rescue Aws::Waiters::Errors::WaiterFailed => error
        puts "failed waiting for instance running: #{error.message}"
      end

    end

  private
    # normalize the params passed to wait_until / describe_images
    def params
      {
        image_ids: [@options[:name]]
      }
    end
  end
end
