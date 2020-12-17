require 'mechanize'

class ScraperRequestService
  def initialize(options = {})
    @url = options[:url]
    @headers = options[:headers]
    @retries = 0
    init_agent
  end

  def init_agent
    @agent = Mechanize.new
    @agent.request_headers = @headers
    @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0'
  end

  def call
    @reponse = @agent.get(@url)
  rescue StandardError => e
    puts 'error.. retrying after a min'
    sleep 5
    retry_request
  end

  def retry_request
    if @retries <= 1
      @retries += 1
      call
    end
  end

end
