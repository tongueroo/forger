module AwsEc2
  class CLI < Command
    class_option :noop, type: :boolean
    class_option :profile, desc: "profile name to use"

    desc "create NAME", "create ec2 instance"
    long_desc Help.text(:create)
    option :ami_name, desc: "when specified, an ami creation script is appended to the user-data script"
    option :auto_terminate, type: :boolean, default: false, desc: "automatically terminate the instance at the end of user-data"
    option :source_ami, desc: "override the source image_id in profile"
    def create(name)
      Create.new(options.merge(name: name)).run
    end

    desc "ami NAME", "launches instance and uses it create AMI"
    long_desc Help.text(:ami)
    option :auto_terminate, type: :boolean, default: true, desc: "automatically terminate the instance at the end of user-data"
    def ami(name)
      Ami.new(options.merge(name: name)).run
    end

    desc "compile_scripts", "compiles app/scripts and app/user-data to tmp folder"
    long_desc Help.text(:compile_scripts)
    def compile_scripts
      Script::Compile.new(options).compile
    end

    desc "upload_scripts", "compiles and uploads scripts to s3"
    long_desc Help.text(:upload_scripts)
    option :compile, type: :boolean, default: true, desc: "compile scripts before uploading"
    def upload_scripts
      Script::Upload.new(options).upload
    end
  end
end
