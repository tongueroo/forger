require "active_support/core_ext/string"

module Forger::Template
  module Helper
    def autoinclude(klass)
      autoload klass, "forger/template/helper/#{klass.to_s.underscore}"
      include const_get(klass)
    end
    extend self

    autoinclude :AmiHelper
    autoinclude :CoreHelper
    autoinclude :PartialHelper
    autoinclude :ScriptHelper
    autoinclude :SshKeyHelper
  end
end
