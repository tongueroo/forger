require "active_support/core_ext/string"

# Encapsulates helper methods and instance variables to be rendered in the ERB
# templates.
module Forger::Template
  class Context
    include Forger::Template::Helper

    def initialize(options={})
      @options = options
      load_variables
      load_custom_helpers
    end

  private
    # Load variables from:
    #   config/variables/development.rb
    #   config/variables/production.rb
    #   etc
    def load_variables
      load_variables_file(:base)
      load_variables_file(Forger.env)
    end

    def load_variables_file(type)
      path = "#{Forger.root}/config/variables/#{type}.rb"
      instance_eval(IO.read(path), path) if File.exist?(path)
    end

    # Load custom helper methods from project
    def load_custom_helpers
      Dir.glob("#{Forger.root}/app/helpers/**/*_helper.rb").each do |path|
        filename = path.sub(%r{.*/},'').sub('.rb','')
        module_name = filename.camelize

        # Prepend a period so require works FORGER_ROOT is set to a relative path
        # without a period.
        #
        # Example: FORGER_ROOT=tmp/project
        first_char = path[0..0]
        path = "./#{path}" unless %w[. /].include?(first_char)
        require path
        self.class.send :include, module_name.constantize
      end
    end
  end
end
