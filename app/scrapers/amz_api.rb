require 'time'
require 'uri'
require 'openssl'
require 'base64'
require 'httparty'

class AmazonAPI

  ENDPOINT = "webservices.amazon.com.br"
  REQUEST_URI = "/onca/xml"

  def generate_request_url(params)
    params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")
    canonical_query_string = params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),
      URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')
    string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'),
      ENV['SECRET_KEY'], string_to_sign)).strip()
    request_url = "https://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature,
      Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  end

  def by_keyword(keywords)
    params = {
      'Service' => 'AWSECommerceService',
      'Operation' => 'ItemSearch',
      'AWSAccessKeyId' => ENV['AMAZON_ID'],
      'AssociateTag' => 'savewhey-20',
      'SearchIndex' => 'All',
      'Keywords' => keywords
    }
    generate_request_url(params)
  end

  def item_look_up(asin)
    params = {
      "Service" => "AWSECommerceService",
      "Operation" => "ItemLookup",
      "AWSAccessKeyId" => ENV['AMAZON_ID'],
      "AssociateTag" => "savewhey-20",
      "ItemId" => asin,
      "IdType" => "ASIN",
      "ResponseGroup" => "Images, ItemAttributes, OfferFull"
    }
    generate_request_url(params)
  end


  def by_asin(asin)
    params = {
      'Service' => 'AWSECommerceService',
      'Operation' => 'ItemSearch',
      'AWSAccessKeyId' => ENV['AMAZON_ID'],
      'AssociateTag' => 'savewhey-20',
      'ItemId' => asin,
      'IdType' => 'ASIN',
      'ResponseGroup' => 'Images,Offers,Small',
      'Condition' => 'New'
    }
    generate_request_url(params)
  end

  def by_keyword_and_category(keywords, category)
    params = {
      'Service' => 'AWSECommerceService',
      'Operation' => 'ItemSearch',
      'AWSAccessKeyId' => ENV['AMAZON_ID'],
      'AssociateTag' => 'savewhey-20',
      'SearchIndex' => category,
      'Keywords' => keywords,
      'ResponseGroup' => 'Images,Offers,Small',
    }
    generate_request_url(params)
  end

end 