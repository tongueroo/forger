require "active_support" # for autoload
require "active_support/core_ext/string"

module Forger
  module Template
    def context
      @context ||= Forger::Template::Context.new(@options)
    end
  end
end
