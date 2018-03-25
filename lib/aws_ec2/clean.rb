module AwsEc2
  autoload :Cleaner, 'aws_ec2/cleaner'

  class Clean < Command
    desc "ami", "Clean until AMI available."
    long_desc Help.text("clean:ami")
    option :keep, type: :numeric, default: 2, desc: "Number of images to keep"
    def ami(query)
      Cleaner::Ami.new(options.merge(query: query)).clean
    end
  end
end
