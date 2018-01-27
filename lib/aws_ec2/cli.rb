module AwsEc2
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"

    desc "create NAME", "create ec2 instance"
    option :ami, desc: "ami name, if specified an ami will be created at the end of user data"
    option :auto_terminate, desc: "automatically terminate the instance at the end of a successfully user-data run"
    long_desc Help.text(:create)
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "userdata NAME", "displays generated userdata script"
    long_desc Help.text(:user_data)
    option :ami, desc: "ami name, if specified an ami will be created at the end of user data"
    option :auto_terminate, desc: "automatically terminate the instance at the end of a successfully user-data run"
    def userdata(name)
      UserData.new(options.merge(name: name)).run
    end

    desc "compile_scripts", "compiles app/scripts into tmp/app/scripts"
    long_desc Help.text(:compile_scripts)
    def compile_scripts
      CompileScripts.new(options).compile
    end
  end
end
