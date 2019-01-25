$:.unshift(File.expand_path("../", __FILE__))
require "forger/version"
require "rainbow/ext/string"
require "render_me_pretty"
require "memoist"

module Forger
  autoload :Ami, "forger/ami"
  autoload :AwsService, "forger/aws_service"
  autoload :Base, "forger/base"
  autoload :Clean, "forger/clean"
  autoload :CLI, "forger/cli"
  autoload :Command, "forger/command"
  autoload :Completer, "forger/completer"
  autoload :Completion, "forger/completion"
  autoload :Config, "forger/config"
  autoload :Core, "forger/core"
  autoload :Create, "forger/create"
  autoload :Destroy, "forger/destroy"
  autoload :Dotenv, "forger/dotenv"
  autoload :Help, "forger/help"
  autoload :Hook, "forger/hook"
  autoload :Network, "forger/network"
  autoload :New, "forger/new"
  autoload :Profile, "forger/profile"
  autoload :Script, "forger/script"
  autoload :Sequence, "forger/sequence"
  autoload :Setting, "forger/setting"
  autoload :Template, "forger/template"
  autoload :Wait, "forger/wait"
  extend Core
end

Forger::Dotenv.load!
