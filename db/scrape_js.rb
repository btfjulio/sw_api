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
            options = ::Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu window-size=1400,900])
            Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts))
        end
        Capybara.configure do |config|  
            config.default_max_wait_time = 10 # seconds
            config.default_driver = :selenium
        end
        browser = Capybara.current_session
        driver = browser.driver.browser
        browser.visit url
        browser.document
        sup = {
          name:   browser.find(:xpath,'//*[@id="content"]/div[2]/div/div[2]/div[2]/h1/span').text,
          link:   "#{url}&utm_source=savewhey&vp=saveblack",
          # store_code:   prod[:sku],
          # seller:   "Saudi Fitness",
          # sender:   "Saudi Fitness",
          # weight: prod[:weight],
          # flavor: prod[:flavor],
          # brand:  prod[:brand],
          price:  browser.find(:xpath,'//*[@id="content"]/div[2]/div/div[2]/div[3]/div[1]/div[2]/div[1]/div[2]/p[1]').text.gsub(/\D/,'').to_i,
          # photo: prod[:photo_url],
          # supershipping: prod[:supershipping],
          # promo: prod[:promo],
          # prime: prod[:prime],
          # store_id: 4 
        }
        puts sup
    end
end


HeadlessBrowser.initialize_browser('https://www.lojacorpoperfeito.com.br/produto/whey-gold-standard-optimum-nutrition?s=10112171481')