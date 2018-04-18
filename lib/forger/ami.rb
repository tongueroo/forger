module Forger
  class Ami < Base
    def run
      # Delegates to the Create command.
      # So we just have to set up the option for it.
      @options[:ami_name] = @name
      Create.new(@options).run
    end
  end
end
