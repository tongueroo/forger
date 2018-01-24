module AwsEc2
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"

    desc "create NAME", "create ec2 instance"
    option :ami, desc: "ami name, if specified an ami will be created at the end of user data"
    long_desc Help.text(:create)
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "spot NAME", "create spot ec2 instance"
    long_desc Help.text(:spot)
    def spot(name)
      Spot.new(options.merge(name: name)).run
    end

    desc "userdata NAME", "displays generated userdata script"
    option :ami, desc: "ami name, if specified an ami will be created at the end of user data"
    long_desc Help.text(:user_data)
    def userdata(name)
      UserData.new(options.merge(name: name)).run
    end
  end
end
