module AwsEc2
  class CLI < Command
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"

    desc "create NAME", "create ec2 instance"
    long_desc Help.text(:create)
    option :ami_name, desc: "when specified, an ami creation script is appended to the user-data script"
    option :auto_terminate, type: :boolean, default: false, desc: "automatically terminate the instance at the end of user-data"
    option :source_ami, desc: "override the source image_id in profile"
    option :randomize, type: :boolean, desc: "append random characters to end of name"
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "ami NAME", "launches instance and uses it create AMI"
    long_desc Help.text(:ami)
    option :auto_terminate, type: :boolean, default: true, desc: "automatically terminate the instance at the end of user-data"
    def ami(name)
      Ami.new(options.merge(name: name)).run
    end

    desc "compile", "compiles app/scripts and app/user-data to tmp folder"
    long_desc Help.text(:compile)
    option :layout, default: "default", desc: "layout for user_data helper"
    def compile
      Script::Compile.new(options).compile
    end

    desc "upload", "compiles and uploads scripts to s3"
    long_desc Help.text(:upload)
    option :compile, type: :boolean, default: true, desc: "compile scripts before uploading"
    def upload
      Script::Upload.new(options).upload
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
