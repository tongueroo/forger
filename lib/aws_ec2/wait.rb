module AwsEc2
  autoload :Waiter, 'aws_ec2/waiter'

  class Wait < Command

    desc "ami", "Wait until AMI available."
    long_desc Help.text("wait:ami")
    def ami(name)
      Waiter::Ami.new(options.merge(name: name)).wait
    end
  end
end
