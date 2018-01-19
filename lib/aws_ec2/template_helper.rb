require "base64"
require "erb"

module AwsEc2
  module TemplateHelper
    def user_data(name)
      # allow user to specify the path also
      if File.exist?(name)
        name = File.basename(name) # normalize name, change path to name
      end
      name = File.basename(name, '.sh')
      path = "#{root}/profiles/user_data/#{name}.sh"
      result = erb_result(path)

      Base64.encode64(result).strip
    end

    def erb_result(path)
      template = IO.read(path)
      begin
        ERB.new(template, nil, "-").result(binding)
      rescue Exception => e
        puts e

        # how to know where ERB stopped? - https://www.ruby-forum.com/topic/182051
        # syntax errors have the (erb):xxx info in e.message
        # undefined variables have (erb):xxx info in e.backtrac
        error_info = e.message.split("\n").grep(/\(erb\)/)[0]
        error_info ||= e.backtrace.grep(/\(erb\)/)[0]
        raise unless error_info # unable to find the (erb):xxx: error line
        line = error_info.split(':')[1].to_i
        puts "Error evaluating ERB template on line #{line.to_s.colorize(:red)} of: #{path.sub(/^\.\//, '')}"

        template_lines = template.split("\n")
        context = 5 # lines of context
        top, bottom = [line-context-1, 0].max, line+context-1
        spacing = template_lines.size.to_s.size
        template_lines[top..bottom].each_with_index do |line_content, index|
          line_number = top+index+1
          if line_number == line
            printf("%#{spacing}d %s\n".colorize(:red), line_number, line_content)
          else
            printf("%#{spacing}d %s\n", line_number, line_content)
          end
        end
        exit 1 unless ENV['TEST']
      end
    end
  end
end
