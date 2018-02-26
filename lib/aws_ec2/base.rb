module AwsEc2
  class Base
    def initialize(options={})
      @options = options.clone
      @name = @options[:name]
      AwsEc2.validate_in_project!
    end

    # Appends a short random string at the end of the ec2 instance name.
    # Later we will strip this same random string from the name.
    # Very makes it convenient.  We can just type:
    #
    #   aws-ec2 create server --randomize
    #
    # instead of:
    #
    #   aws-ec2 create server-123 --profile server
    #
    def randomize(name)
      if @options[:randomize]
        random = (0...3).map { (65 + rand(26)).chr }.join.downcase # Ex: jhx
        [name, random].join('-')
      else
        name
      end
    end
  end
end
