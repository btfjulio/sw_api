# Require the gems
require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
# Configurations
class HeadlessBrowser

    def self.initialize_browser(url)
        chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)

        chrome_opts = chrome_bin ? { "chromeOptions" => { "binary" => chrome_bin } } : {}

        Capybara.register_driver :selenium do |app|  
            options = ::Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu window-size=1400,900 ignore-ssl-errors=yes load-images=no ssl-protocol=any])
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts))
        end
        Capybara.configure do |config|  
            config.default_max_wait_time = 10 # seconds
            config.default_driver = :selenium
        end
        browser = Capybara.current_session
        driver = browser.driver.browser
        browser.visit url
        browser.body
        # browser.has_xpath?('//body/main/div[2]/section/section[3]/div[1]/div[1]/div[1]/img')
    end
end