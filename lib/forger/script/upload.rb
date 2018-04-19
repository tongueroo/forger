require 'filesize'
require 'aws-sdk-s3'
require 'fileutils'

# Class for forger upload command
class Forger::Script
  class Upload < Forger::Base
    def initialize(options={})
      @options = options
      @compile = @options[:compile] ? @options[:compile] : true
    end

    def run
      compiler.compile_scripts if @compile
      compressor.compress
      upload(tarball_path)
      compressor.clean
      compiler.clean if @compile and Forger.settings["compile_clean"]
    end

    def upload(tarball_path)
      puts "Uploading scripts.tgz (#{filesize}) to #{s3_dest}".colorize(:green)
      obj = s3_resource.bucket(bucket_name).object(key)
      start_time = Time.now
      if @options[:noop]
        puts "NOOP: Not uploading file to s3"
      else
        obj.upload_file(tarball_path)
      end
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

    # Removes s3://bucket-name and adds Forger.env. Example:
    #   s3_folder: s3://infra-bucket/ec2
    #   bucket_name: ec2/development/scripts
    def dest_folder
      folder = s3_folder.sub('s3://','').split('/')[1..-1].join('/')
      "#{folder}/#{Forger.env}/scripts"
    end

    # s3_folder example:
    def s3_folder
      Forger.settings["s3_folder"]
    end

    def s3_resource
      return @s3_resource if @s3_resource

      options = {}
      # allow override of region for s3 client to avoid warning:
      # S3 client configured for "us-east-1" but the bucket "xxx" is in "us-west-2"; Please configure the proper region to avoid multiple unnecessary redirects and signing attempts
      # Example: endpoint: 'https://s3.us-west-2.amazonaws.com'
      options[:endpoint] = ENV['S3_ENDPOINT'] if ENV['S3_ENDPOINT']
      if options[:endpoint]
        options[:region] = options[:endpoint].split('.')[1]
      end
      @s3_resource = Aws::S3::Resource.new(options)
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
