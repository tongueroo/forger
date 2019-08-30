$:.unshift(File.expand_path("../", __FILE__))
require "forger/version"
require "rainbow/ext/string"
require "render_me_pretty"
require "memoist"

require "forger/autoloader"
Forger::Autoloader.setup

module Forger
  extend Core
end

Forger::Dotenv.load!
Forger.set_aws_profile!
