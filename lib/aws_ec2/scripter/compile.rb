require 'fileutils'

# Class for aws-ec2 compile command
class AwsEc2::Scripter
  class Compile < AwsEc2::Base
    include AwsEc2::Template

    def compile
      clean
      compile_folder("scripts")
      compile_folder("user-data")
    end

    def compile_folder(folder)
      puts "Compiling app/#{folder}:".colorize(:green)
      Dir.glob("#{AwsEc2.root}/app/#{folder}/**/*").each do |path|
        next if File.directory?(path)
        result = RenderMePretty.result(path, context: context)
        tmp_path = path.sub(%r{.*/app/}, "#{BUILD_ROOT}/app/")
        puts "  #{tmp_path}"
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
    end

    def clean
      FileUtils.rm_rf("#{BUILD_ROOT}/app")
    end
  end
end
