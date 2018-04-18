require "thor"

# Override thor's long_desc identation behavior
# https://github.com/erikhuda/thor/issues/398
class Thor
  module Shell
    class Basic
      def print_wrapped(message, options = {})
        message = "\n#{message}" unless message[0] == "\n"
        stdout.puts message
      end
    end
  end
end

module Forger
  class Command < Thor
    class << self
      def dispatch(m, args, options, config)
        # Allow calling for help via:
        #   forger command help
        #   forger command -h
        #   forger command --help
        #   forger command -D
        #
        # as well thor's normal way:
        #
        #   forger help command
        help_flags = Thor::HELP_MAPPINGS + ["help"]
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end

        #   forger version
        #   forger --version
        #   forger -v
        version_flags = ["--version", "-v"]
        if args.length == 1 && !(args & version_flags).empty?
          args = ["version"]
        end

        super
      end

      # Override command_help to include the description at the top of the
      # long_description.
      def command_help(shell, command_name)
        meth = normalize_command_name(command_name)
        command = all_commands[meth]
        alter_command_description(command)
        super
      end

      def alter_command_description(command)
        return unless command
        long_desc = if command.long_description
            "#{command.description}\n\n#{command.long_description}"
          else
            command.description
          end
        command.long_description = long_desc
      end
      private :alter_command_description
    end
  end
end
