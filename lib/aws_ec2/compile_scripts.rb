require 'fileutils'

module AwsEc2
  class CompileScripts
    include TemplateHelper

    def initialize(options)
      @options = options
    end

    def compile
      puts "Compiling app/scripts..."
      Dir.glob("#{AwsEc2.root}/app/scripts/**/*").each do |path|
        next if File.directory?(path)
        result = erb_result(path)
        tmp_path = path.sub("/app/", "/tmp/app/")
        puts "  #{tmp_path}"
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
      puts "Compiled app/scripts."
    end
  end
end
