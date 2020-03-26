require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page


class PostsUpdater
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by
  STORES_HELPERS = {
    "Netshoes": {
      regexs: [/(\w|\d){3}-\d{4}-(\w|\d)\d{2}/, /(\w|\d){3}-\d{4}/],
      identifier: ""
    },
    "Corpo Ideal": {
      regexs: [/(?<=s\=)(\d*)/, /(?<=id\=)(\d*)/],
      identifier: "ci-"
    },
    "Corpo Perfeito": {
      regexs: [/(?<=s\=)(\d*)/, /(?<=id\=)(\d*)/],
      identifier: "cp-"
    },
    "Centauro": {
      regexs: [/(?<=\-)(\d|\w){2}\d{2}(\d|\w){2}/],
      identifier: "centauro-"
    },
    "Amazon": {
      regexs: [/(?<=ASIN\=)(\d|\w)*/],
      identifier: ""
    }
  }
  
  def initialize
    @page = 1
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
  end

  def get_app_products
    get_api_info()
    puts "App Products infos collected"
  end
  
  def get_api_info
    while true do  
      api_info = make_request()
        break unless get_products(api_info)
        @page += 1
    end
  end

  def make_request
    api_endpoint = "https://api.goodbarber.net/front/get_items/948226/14993072/?page=#{@page}&per_page=24"
    response = @agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
  end
  
  
  def get_products(api_info)
    posts = api_info['items']
    return false if posts.empty?
    posts.each do |post|
      post_update = parse_post(post)
      next if post_update.nil?
      suplemento = find_suplemento(post_update[:link])
      if suplemento
        post_update[:suplemento_id]  = suplemento.id
      end
      saved_post = save_post(post_update)
      puts "#{saved_post.title}"
    end 
  end

  def parse_post(post)
    begin
      client = Bitly.client
      bitlink = get_content(post, /(?<=href=\").*?(?=\">Me leve)/)
      post_update = {
        title: post["title"],
        img: get_content(post, /(?<=\<p><img src\=\").*?(?=\" class)/),
        coupon: get_content(post,/(?<=Cupom:).*?(?=<\/strong)/),
        online: true,
        updated: true,
        price: get_price(post["content"]),
        link: client.expand(bitlink).long_url,
        clicks: client.clicks(bitlink).user_clicks,   
      }
    rescue => exception
      puts exception
    end
  end

  def get_content(post, regex)
    content = post["content"].match(regex)
    content.to_s.strip if content
  end

  def find_suplemento(link)
    store = Store.all.filter { |store| link.match(store.name.downcase.gsub(" ", "")) }.first
    if store 
      store_code = get_store_code(store.name, link)
      Suplemento.search_store_code(store_code).first
    else
      nil
    end
  end
  
  def get_store_code(store_name, link)
    begin
      store = STORES_HELPERS[store_name.to_sym]
      store[:regexs].each do |regex|
        code = link.match(regex)
        if code
          return "#{store[:identifier]}#{code}"
        end 
      end
    rescue => exception
      puts exception  
    end
  end
  
  def save_post(post_update)
    post = Post.where(link: post_update[:link])&.first
    post ? post.update(post_update) : (post = Post.create(post_update))
    post
  end
  
  def get_price(title)
    price = title.match(/\$([0-9\.]+)\b/)
    price[1]&.to_i unless price.nil?; 
  end
  
end