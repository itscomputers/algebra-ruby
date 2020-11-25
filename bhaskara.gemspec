require File.expand_path("../lib/bhaskara/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "bhaskara"
  s.version == Bhaskara::VERSION

  s.required_ruby_version = "= 2.6.1"

  s.authors = ["itscomputers"]
  s.email = ["its_computers@protonmail.com"]
  s.summary = "An abstract algebra gem"
  s.description = s.summary
  s.licenses = ["MIT"]

  s.executables = []
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 2.1"
end

