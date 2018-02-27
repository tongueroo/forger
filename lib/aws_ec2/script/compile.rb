require 'fileutils'

# Class for aws-ec2 compile command
class AwsEc2::Script
  class Compile < AwsEc2::Base
    include AwsEc2::Template

    def compile_scripts
      clean
      compile_folder("scripts")
    end

    def compile_user_data
      clean
      compile_folder("user-data")
    end

    def compile_all
      clean
      compile_folder("scripts")
      compile_folder("user-data")
    end

    def compile_folder(folder)
      layout_path = layout_path(@options[:layout])

      puts "Compiling app/#{folder}:".colorize(:green)
      Dir.glob("#{AwsEc2.root}/app/#{folder}/**/*").each do |path|
        next if File.directory?(path)

        result = RenderMePretty.result(path, layout: layout_path, context: context)
        tmp_path = path.sub(%r{.*/app/}, "#{BUILD_ROOT}/app/")
        puts "  #{tmp_path}"
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
    end

    # Get full path of layout from layout name
    def layout_path(name)
      return nil unless name

      ext = File.extname(name)
      name += ".sh" if ext.empty?
      path = "#{AwsEc2.root}/app/layouts/#{name}"
      unless File.exist?(path)
        puts "ERROR: Layout #{path} does not exist. Are you sure it exists?  Exiting".colorize(:red)
        exit 1
      end
      path
    end

    def clean
      FileUtils.rm_rf("#{BUILD_ROOT}/app")
    end
  end
end
