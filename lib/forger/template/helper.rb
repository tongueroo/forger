require "active_support/core_ext/string"

module Forger::Template
  module Helper
    include AmiHelper
    include CoreHelper
    include PartialHelper
    include ScriptHelper
    include SshKeyHelper
    extend self
  end
end
