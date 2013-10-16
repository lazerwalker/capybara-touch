require "capybara"

module Capybara
  module Touch
  end
end

require "capybara/touch/driver"

Capybara.register_driver :iphone do |app|
  Capybara::Touch::Driver.new(app, device: :iphone)
end

Capybara.register_driver :ipad do |app|
  Capybara::Touch::Driver.new(app, device: :ipad)
end
