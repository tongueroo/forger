require 'filesize'
require 'aws-sdk-s3'
require 'fileutils'
require 'memoist'

# Class for forger upload command
class Forger::Script
  class Upload < Forger::Base
    extend Memoist

    def initialize(options={})
      @options = options
      @compile = @options[:compile] ? @options[:compile] : true
    end

    def run
      compiler.compile_scripts if @compile
      ensure_bucket_exists
      compressor.compress
      upload(tarball_path)
      compressor.clean
      compiler.clean if @compile and Forger.settings["compile_clean"]
    end

    def ensure_bucket_exists
      Forger::S3::Bucket.ensure_exists! if Forger::Template::Helper.extract_scripts_registered?
    end

    def upload(tarball_path)
      if @options[:noop]
        puts "NOOP: Not uploading file to s3"
        return
      end

      puts "Uploading scripts.tgz (#{filesize}) to #{s3_dest}".color(:green)
      obj = s3_resource.bucket(bucket_name).object(s3_key)
      start_time = Time.now
      obj.upload_file(tarball_path)
      time_took = pretty_time(Time.now-start_time).color(:green)
      puts "Time to upload code to s3: #{time_took}"
    end

    def empty?
      Dir.glob("#{Forger.root}/app/scripts/**/*").select do |path|
        File.file?(path)
      end.empty?
    end

    def tarball_path
      IO.read(SCRIPTS_INFO_PATH).strip
    end

    def filesize
      Filesize.from(File.size(tarball_path).to_s + " B").pretty
    end

    def s3_dest
      "s3://#{bucket_name}/#{s3_key}"
    end

    def s3_key
      # Example s3_key: ec2/development/scripts/scripts-md5
      dest_folder = "#{Forger.env}/scripts"
      "#{dest_folder}/#{File.basename(tarball_path)}"
    end

    def bucket_name
      Forger::S3::Bucket.name
    end

    def s3_resource
      options = {}
      # allow override of region for s3 client to avoid warning:
      # S3 client configured for "us-east-1" but the bucket "xxx" is in "us-west-2"; Please configure the proper region to avoid multiple unnecessary redirects and signing attempts
      # Example: endpoint: 'https://s3.us-west-2.amazonaws.com'
      options[:endpoint] = ENV['FORGER_S3_ENDPOINT'] if ENV['FORGER_S3_ENDPOINT']
      if options[:endpoint]
        options[:region] = options[:endpoint].split('.')[1]
      end
      Aws::S3::Resource.new(options)
    end
    memoize :s3_resource

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
