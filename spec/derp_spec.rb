require 'capybara/rspec'
require 'capybara-webkit'

Capybara.default_driver = :webkit

describe "when searching for kitties", :type => :feature do
  it "should show some kitties" do
    visit 'http://google.com'
    fill_in 'q', :with => 'kitties'
    click_button 'Google Search'
    page.should have_content 'Images for kitties'
  end
end