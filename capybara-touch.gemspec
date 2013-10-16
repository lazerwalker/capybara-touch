$:.push File.expand_path("../lib", __FILE__)
require "capybara/touch/version"

Gem::Specification.new do |s|
  s.name     = "capybara-touch"
  s.version  = Capybara::Driver::Touch::VERSION.dup
  s.authors  = ["Mike Walker"]
  s.email    = "michael@lazerwalker.com"
  s.homepage = "http://github.com/lazerwalker/capybara-touch"
  s.summary  = "Mobile Webkit driver for Capybara"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_path = "lib"

  s.required_ruby_version = ">= 1.9.0"

  s.add_runtime_dependency("capybara", "~> 2.0", ">= 2.0.2")

  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("rake")
end

