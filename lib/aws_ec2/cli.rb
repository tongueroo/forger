module AwsEc2
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"
    class_option :show_user_data, type: :boolean, desc: "do not summarize userdata, show the full script"

    # common options between create and userdata
    create_options = Proc.new do
      option :ami_name, desc: "when specified, an ami creation script is appended to the user-data script"
    end

    desc "create NAME", "create ec2 instance"
    long_desc Help.text(:create)
    create_options.call
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "userdata NAME", "displays generated userdata script"
    long_desc Help.text(:user_data)
    create_options.call
    def userdata(name)
      UserData.new(options.merge(name: name)).run
    end

    desc "ami NAME", "laucnhes instance and uses it create AMI"
    long_desc Help.text(:ami)
    option :auto_terminate, default: true, desc: "automatically terminate the instance at the end of a successfully user-data run"
    def ami(name)
      Ami.new(options.merge(name: name)).run
    end

    desc "compile_scripts", "compiles app/scripts into tmp/app/scripts"
    long_desc Help.text(:compile_scripts)
    def compile_scripts
      CompileScripts.new(options).compile
    end
  end
end
