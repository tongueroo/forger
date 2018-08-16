require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

class Forger::Sequence < Thor::Group
  include Thor::Actions
  # include Forger::Helper

  def self.source_root
    template = ENV['TEMPLATE'] || 'default'
    File.expand_path("../../templates/#{template}", __FILE__)
  end

private
  def copy_project
    puts "Creating new forger project called #{project_name}."
    directory ".", project_name
  end

  def git_installed?
    system("type git > /dev/null")
  end
end
