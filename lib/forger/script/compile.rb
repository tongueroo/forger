require 'fileutils'

# Class for forger compile command
class Forger::Script
  class Compile < Forger::Base
    include Forger::Template

    # used in upload
    def compile_scripts
      clean
      compile_folder("scripts")
    end

    # use in compile cli command
    def compile_all
      clean
      compile_folder("scripts")
      layout_path = context.layout_path(@options[:layout])
      compile_folder("user-data", layout_path)
    end

    def compile_folder(folder, layout_path=false)
      puts "Compiling app/#{folder} to tmp/app/#{folder}.".color(:green)
      Dir.glob("#{Forger.root}/app/#{folder}/**/*").each do |path|
        next if File.directory?(path)
        next if path.include?("layouts")

        result = RenderMePretty.result(path, layout: layout_path, context: context)
        tmp_path = path.sub(%r{.*/app/}, "#{BUILD_ROOT}/app/")
        puts "  #{tmp_path}" if @options[:verbose]
        FileUtils.mkdir_p(File.dirname(tmp_path))
        IO.write(tmp_path, result)
      end
    end

    def clean
      FileUtils.rm_rf("#{BUILD_ROOT}/app")
    end
  end
end
