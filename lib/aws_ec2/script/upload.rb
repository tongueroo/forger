require 'filesize'
require 'aws-sdk-s3'
require 'fileutils'

# Class for aws-ec2 upload command
class AwsEc2::Script
  class Upload < AwsEc2::Base
    def initialize(options={})
      @options = options
      @compile = @options[:compile] ? @options[:compile] : true
    end

    def run
      compiler.compile if @compile
      compressor.compress
      upload(tarball_path)
      compressor.clean
      compiler.clean if @compile and AwsEc2.settings["compile_clean"]
    end

    def upload(tarball_path)
      puts "Uploading scripts.tgz (#{filesize}) to #{s3_dest}"
      obj = s3_resource.bucket(bucket_name).object(key)
      start_time = Time.now
      obj.upload_file(tarball_path)
      time_took = pretty_time(Time.now-start_time).colorize(:green)
      puts "Time to upload code to s3: #{time_took}"
    end

    def tarball_path
      IO.read(SCRIPTS_INFO_PATH).strip
    end

    def filesize
      Filesize.from(File.size(tarball_path).to_s + " B").pretty
    end

    def s3_dest
      "s3://#{bucket_name}/#{key}"
    end

    def key
      # Example key: ec2/development/scripts/scripts-md5
      "#{dest_folder}/#{File.basename(tarball_path)}"
    end

    # Example:
    #   s3_folder: s3://infra-bucket/ec2
    #   bucket_name: infra-bucket
    def bucket_name
      s3_folder.sub('s3://','').split('/').first
    end

    # Removes s3://bucket-name and adds AwsEc2.env. Example:
    #   s3_folder: s3://infra-bucket/ec2
    #   bucket_name: ec2/development/scripts
    def dest_folder
      folder = s3_folder.sub('s3://','').split('/')[1..-1].join('/')
      "#{folder}/#{AwsEc2.env}/scripts"
    end

    # s3_folder example:
    def s3_folder
      AwsEc2.settings["s3_folder"]
    end

    def s3_resource
      @s3_resource ||= Aws::S3::Resource.new
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end

    def sh(command)
      puts "=> #{command}"
      system command
    end

    def compiler
      @compiler ||= Compile.new(@options)
    end

    def compressor
      @compressor ||= Compress.new(@options)
    end
  end
end
