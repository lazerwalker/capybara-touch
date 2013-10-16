require 'capybara/rspec'
require 'capybara-touch'
require 'capybara-webkit'

Capybara.default_driver = :iphone

describe "when searching for kitties", :type => :feature do
  it "should show some kitties" do
    visit 'http://duckduckgo.com'
    fill_in 'q', :with => 'kitties'
    click_button 'search_button_homepage'
    page.should have_content 'A kitten or kitty is a juvenile domesticated cat.'
  end
end