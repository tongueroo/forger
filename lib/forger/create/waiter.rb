class Forger::Create
  class Waiter < Forger::Base
    include Forger::AwsService

    def wait
      @instance_id = @options[:instance_id]
      handle_wait if wait?
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
      puts "Instance public dns name: #{dns}"

      if i.public_dns_name && !@options[:ssh]
        command = build_ssh_command(i.public_dns_name)
        puts "Ssh command below. Note the user might be different. You can specify --ssh-user=USER.  You can also ssh automatically into the instance with the --ssh flag."
        display_ssh(command)
      end

      i
    end

    def handle_ssh
      instance = handle_wait
      unless instance.public_dns_name
        puts "This instance does not have a public dns for ssh."
        return
      end

      command = build_ssh_command(instance.public_dns_name)
      display_ssh(command)
      retry_until_success(command)
      Kernel.exec(*command) unless @options[:noop]
    end

    def wait?
      return false if @options[:ssh]
      @options[:wait]
    end

    def build_ssh_command(host)
      user = @options[:ssh_user] || "ec2-user"
      [
        "ssh",
        ENV['SSH_OPTIONS'],
        "#{user}@#{host}"
      ].compact
    end

    def display_ssh(command)
      puts "=> #{command.join(' ')}".colorize(:green)
    end

    def retry_until_success(*command)
      retries = 0
      uptime = command + ['uptime', '2>&1']
      uptime = uptime.join(' ')
      out = `#{uptime}`
      while out !~ /load average/ do
        puts "Can't ssh into the server yet.  Retrying until success. (Timeout 10m)" if retries == 0
        print '.'
        retries += 1
        if retries > 600 # Timeout after 10 minutes
          raise "ERROR: Timeout after 600 seconds, cannot connect to the server."
        end
        sleep 1
        out = `#{uptime}`
      end
      puts ""
    end
  end
end
