class Forger::Create
  class Waiter < Forger::Base
    include Forger::AwsService

    def wait
      @instance_id = @options[:instance_id]
      handle_wait if @options[:wait]
      handle_ssh if @options[:ssh]
    end

    def handle_wait
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
      i
    end

    def handle_ssh
      instance = handle_wait
      unless instance.public_dns_name
        puts "This instance does not have a public dns for ssh."
        return
      end

      command = build_ssh_command(instance.public_dns_name)
      puts "=> #{command.join(' ')}".colorize(:green)
      retry_until_success(command)
      Kernel.exec(*command) unless @options[:noop]
    end

    def build_ssh_command(host)
      user = @options[:ssh_user] || "ec2-user"
      [
        "ssh",
        ENV['SSH_OPTIONS'],
        "#{user}@#{host}"
      ].compact
    end

    def retry_until_success(*command)
      retries = 0
      uptime = command + ['uptime', '2>&1']
      uptime = uptime.join(' ')
      out = `#{uptime}`
      while out !~ /load average/ do
        puts "Can't ssh into the server yet.  Retrying until success." if retries == 0
        print '.'
        retries += 1
        sleep 1
        out = `#{uptime}`
      end
      puts ""
    end
  end
end
