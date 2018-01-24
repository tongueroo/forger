# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aws_ec2/version"

Gem::Specification.new do |spec|
  spec.name          = "aws-ec2"
  spec.version       = AwsEc2::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.description   = %q{Simple tool to create AWS ec2 instances consistently with pre-configured settings}
  spec.summary       = %q{Simple tool to create AWS ec2 instances}
  spec.homepage      = "https://github.com/tongueroo/aws-ec2"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "hashie"
  spec.add_dependency "colorize"
  spec.add_dependency "dotenv"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
end
