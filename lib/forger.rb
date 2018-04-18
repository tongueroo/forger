$:.unshift(File.expand_path("../", __FILE__))
require "forger/version"
require "colorize"
require "render_me_pretty"

module Forger
  autoload :Help, "forger/help"
  autoload :Command, "forger/command"
  autoload :CLI, "forger/cli"
  autoload :AwsService, "forger/aws_service"
  autoload :Profile, "forger/profile"
  autoload :Base, "forger/base"
  autoload :Create, "forger/create"
  autoload :Ami, "forger/ami"
  autoload :Wait, "forger/wait"
  autoload :Clean, "forger/clean"
  autoload :Template, "forger/template"
  autoload :Script, "forger/script"
  autoload :Config, "forger/config"
  autoload :Core, "forger/core"
  autoload :Dotenv, "forger/dotenv"
  autoload :Hook, "forger/hook"
  autoload :Completion, "forger/completion"
  autoload :Completer, "forger/completer"
  autoload :Setting, "forger/setting"
  extend Core
end

Forger::Dotenv.load!
