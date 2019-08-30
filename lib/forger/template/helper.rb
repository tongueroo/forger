require "active_support/core_ext/string"

module Forger::Template
  module Helper
    include AmiHelper
    include CoreHelper
    include PartialHelper
    include ScriptHelper
    include SshKeyHelper
    extend self

    @@extract_scripts_registered = false
    def extract_scripts_registered?
      @@extract_scripts_registered
    end
  end
end
