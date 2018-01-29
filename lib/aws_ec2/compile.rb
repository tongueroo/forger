require 'fileutils'

module AwsEc2
  class Compile < Base
    include TemplateHelper
    BUILD_ROOT = "tmp"

    def compile
      clean
      compile_folder("scripts")
      compile_folder("user-data")
    end

    def compile_folder(folder)
      puts "Compiling app/#{folder}:"
      Dir.glob("#{AwsEc2.root}/app/#{folder}/**/*").each do |path|
        next if File.directory?(path)
        result = erb_result(path)
        tmp_path = path.sub(%r{.*/app/}, "#{BUILD_ROOT}/app/")
        puts "  #{tmp_path}"
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
    end

    def clean
      FileUtils.rm_rf(BUILD_ROOT)
    end
  end
end
