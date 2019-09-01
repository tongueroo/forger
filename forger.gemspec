# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "forger/version"

Gem::Specification.new do |spec|
  spec.name          = "forger"
  spec.version       = Forger::VERSION
  spec.author        = "Tung Nguyen"
  spec.email         = "tongueroo@gmail.com"
  spec.summary       = "Create EC2 Instances with preconfigured settings"
  spec.homepage      = "https://github.com/tongueroo/forger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "aws-sdk-cloudformation"
  spec.add_dependency "aws-sdk-ec2"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "cfn-status"
  spec.add_dependency "dotenv"
  spec.add_dependency "filesize"
  spec.add_dependency "hashie"
  spec.add_dependency "memoist"
  spec.add_dependency "rainbow"
  spec.add_dependency "render_me_pretty"
  spec.add_dependency "thor"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake"
end
