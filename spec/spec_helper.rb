require 'rspec'
require 'rspec/autorun'
require 'rbconfig'
require 'capybara'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

require 'capybara/touch'
connection = Capybara::Touch::Connection.new(:device => "ipad")
$webkit_browser = Capybara::Touch::Browser.new(connection)

require 'capybara/spec/spec_helper'

Capybara.register_driver :reusable_touch do |app|
  Capybara::Touch::Driver.new(app, :browser => $webkit_browser)
end

RSpec.configure do |c|
  Capybara::SpecHelper.configure(c)
end

def with_env_vars(vars)
  old_env_variables = {}
  vars.each do |key, value|
    old_env_variables[key] = ENV[key]
    ENV[key] = value
  end

  yield

  old_env_variables.each do |key, value|
    ENV[key] = value
  end
end
