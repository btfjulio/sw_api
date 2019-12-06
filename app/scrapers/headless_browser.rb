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
            options = ::Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu headless window-size=1400,900 referrer=https://google.com accept-language=en-US,en;q=0.9 ignore-ssl-errors=yes load-images=no ssl-protocol=any] << "--user-agent='#{user_agent}'")
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts))
        end
        Capybara.javascript_driver = :headless_chrome
        Capybara.configure do |config| 
            config.run_server = false
            config.app_host   = 'http://www.google.com' 
            config.default_max_wait_time = 10 # seconds
            config.default_driver = :selenium
        end
        # Capybara.current_driver = Capybara.javascript_driver
        browser = Capybara.current_session
        driver = browser.driver.browser
        browser.visit url
        sleep(2) 
        doc = browser.body
        # rowser.driver.browser.close
        doc
    end
end