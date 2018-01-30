require 'fileutils'

# Class for aws-ec2 upload_scripts command
class AwsEc2::Script
  class Upload < AwsEc2::Base
    def initialize(options={})
      @options = options
      @compile = @options[:compile] ? @options[:compile] : true
    end

    def upload
      compiler.compile if @compile
      sync_scripts_to_s3
      compiler.clean if @compile and !ENV['AWS_EC2_KEEP']
    end

    def sync_scripts_to_s3
      puts "Uploading tmp/app to s3..."
      s3_bucket = AwsEc2.config["scripts_s3_bucket"]
      s3_path = AwsEc2.config["scripts_s3_path"] || "ec2/app"
      sh "aws s3 sync tmp/app s3://#{s3_bucket}/#{s3_path}"
    end

    def sh(command)
      puts "=> #{command}"
      system command
    end

    def compiler
      @compiler ||= Compile.new(@options)
    end
  end
end
