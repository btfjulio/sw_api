# Require the gems
require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
# Configurations
class HeadlessBrowser

    def self.initialize_browser(url)
        chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)

        Capybara.register_driver :selenium do |app|  
            options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu window-size=1400,900])
            options.binary = chrome_bin
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
        end
        Capybara.configure do |config|  
            config.default_max_wait_time = 10 # seconds
            config.default_driver = :selenium
        end
        browser = Capybara.current_session
        driver = browser.driver.browser
        browser.visit url
        browser.has_xpath?('//body/main/div[2]/section/section[3]/div[1]/div[1]/div[1]/img')
    end
end