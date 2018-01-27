require 'fileutils'

module AwsEc2
  class CompileScripts
    include TemplateHelper
    BUILD_ROOT = "tmp"

    def initialize(options)
      @options = options
    end

    def compile
      puts "Compiling app/scripts to..."
      clean
      Dir.glob("#{AwsEc2.root}/app/scripts/**/*").each do |path|
        next if File.directory?(path)
        result = erb_result(path)
        tmp_path = path.sub(%r{.*/app/}, "#{BUILD_ROOT}/app/")
        puts "  #{tmp_path}"
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
      puts "Compiled app/scripts."
    end

    def clean
      FileUtils.rm_rf(BUILD_ROOT)
    end
  end
end
