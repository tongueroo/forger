module Forger
  class CLI < Command
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"

    desc "clean SUBCOMMAND", "clean subcommands"
    long_desc Help.text(:clean)
    subcommand "clean", Clean

    desc "wait SUBCOMMAND", "wait subcommands"
    long_desc Help.text(:wait)
    subcommand "wait", Wait

    common_options = Proc.new do
      option :auto_terminate, type: :boolean, default: false, desc: "automatically terminate the instance at the end of user-data"
      option :cloudwatch, type: :boolean, default: false, desc: "enable cloudwatch logging, supported for amazonlinux2 and ubuntu"
    end

    desc "create NAME", "create ec2 instance"
    long_desc Help.text(:create)
    option :ami_name, desc: "when specified, an ami creation script is appended to the user-data script"
    option :randomize, type: :boolean, desc: "append random characters to end of name"
    option :source_ami, desc: "override the source image_id in profile"
    common_options.call
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "ami NAME", "launches instance and uses it create AMI"
    long_desc Help.text(:ami)
    common_options.call
    def ami(name)
      Ami.new(options.merge(name: name)).run
    end

    desc "compile", "compiles app/scripts and app/user-data to tmp folder"
    long_desc Help.text(:compile)
    option :layout, default: "default", desc: "layout for user_data helper"
    def compile
      Script::Compile.new(options).compile_all
    end

    desc "upload", "compiles and uploads scripts to s3"
    long_desc Help.text(:upload)
    option :compile, type: :boolean, default: true, desc: "compile scripts before uploading"
    def upload
      Script::Upload.new(options).upload
    end

    desc "destroy", "Destroys instance accounting for spot request"
    long_desc Help.text("destroy")
    def destroy(instance_id)
      Destroy.new(options).run(instance_id)
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text("completion")
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion."
    long_desc Help.text("completion_script")
    def completion_script
      Completer::Script.generate
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end
  end
end
