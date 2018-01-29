module AwsEc2
  class S3
    def initialize(options={})
      @options = options
    end

    def upload(skip_compile=false)
      compiler.compile unless skip_compile
      sync_scripts_to_s3
      compiler.clean unless ENV['AWS_EC2_KEEP'] || skip_compile
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
