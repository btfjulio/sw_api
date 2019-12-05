# Require the gems
require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'
# Configurations
class HeadlessBrowser

    def self.initialize_browser(url)
        chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)

        chrome_opts = chrome_bin ? { "chromeOptions" => { "binary" => chrome_bin } } : {}
        user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3'
        Capybara.register_driver :selenium do |app|  
            options = ::Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu headless window-size=1400,900 ignore-ssl-errors=yes load-images=no ssl-protocol=any] << "--user-agent='#{user_agent}'")
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts))
        end
        Capybara.configure do |config|  
            config.default_max_wait_time = 10 # seconds
            config.default_driver = :selenium
        end
        browser = Capybara.current_session
        driver = browser.driver.browser
        browser.visit url
        sleep(2) 
        browser.body
        # browser.has_xpath?('//body/main/div[2]/section/section[3]/div[1]/div[1]/div[1]/img')
    end
end