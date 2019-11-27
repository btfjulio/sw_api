# Require the gems
require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
# Configurations
Capybara.register_driver :selenium do |app|  
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.javascript_driver = :chrome

Capybara.configure do |config|  
  config.default_max_wait_time = 10 # seconds
  config.default_driver = :selenium
end
# Visit

browser = Capybara.current_session
driver = browser.driver.browser
browser.visit "https://www.netshoes.com.br/creatina-black-skull-300g-sem+sabor-G54-0231-289"

result = browser.has_xpath?('//body/main/div[2]/section/section[3]/div[1]/div[1]/div[1]/img')
# browser.find('.keyword-input').set("test")
# browser.find('.keyword-input').native.send_keys(:return)
puts result
doc = Nokogiri::HTML(driver.page_source);
# puts doc