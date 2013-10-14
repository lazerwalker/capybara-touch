require "capybara"

module Capybara
  module Touch
  end
end

require "capybara/touch/driver"

p "HI MOM"
Capybara.register_driver :ios do |app|
  Capybara::Touch::Driver.new(app)
end
