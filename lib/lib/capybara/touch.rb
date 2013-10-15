require "capybara"

module Capybara
  module Touch
  end
end

require "capybara/touch/driver"

Capybara.register_driver :ios do |app|
  Capybara::Touch::Driver.new(app)
end
