class Forger::Create
  class Waiter < Forger::Base
    include Forger::AwsService

    def wait
      @instance_id = @options[:instance_id]
      handle_wait
      handle_ssh
    end

    def handle_wait
      return unless @options[:wait]

      puts "Waiting for instance #{@instance_id} to be ready."
      # https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/using-waiters.html
      ec2.wait_until(:instance_running, instance_ids:[@instance_id]) do |w|
        w.interval = 5
        w.before_wait do |n, resp|
          print '.'
        end
      end
      puts "" # newline

      resp = ec2.describe_instances(instance_ids:[@instance_id])
      i = resp.reservations.first.instances.first
      puts "Instance #{@instance_id} is ready"
      dns = i.public_dns_name ? i.public_dns_name : 'nil'
      puts "Instance public_dns_name: #{dns}"
    end

    def handle_ssh
      return unless @options[:ssh]
    end
  end
end
