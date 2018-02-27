require 'fileutils'

# Class for aws-ec2 compile command
class AwsEc2::Script
  class Compile < AwsEc2::Base
    include AwsEc2::Template

    # used in upload
    def compile_scripts
      clean
      compile_folder("scripts")
    end

    # use in compile cli command
    def compile_all
      clean
      compile_folder("scripts") # TODO: turn off for debugging
      layout_path = context.layout_path(@options[:layout])
      compile_folder("user-data", layout_path)
    end

    def compile_folder(folder, layout_path=false)
      puts "Compiling app/#{folder}:".colorize(:green)
      Dir.glob("#{AwsEc2.root}/app/#{folder}/**/*").each do |path|
        next if File.directory?(path)
        next if path.include?("layouts")

        result = RenderMePretty.result(path, layout: layout_path, context: context)
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
