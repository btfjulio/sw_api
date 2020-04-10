class AmazonAPI
  ENDPOINT = "webservices.amazon.com.br/paapi5/getitems"

  def generate_headers_url(headers)
    
  end

  def generate_request_url(params)
    params["Timestamp"] = Time.now.gmtime.iso8601 unless params.key?("Timestamp")
    canonical_query_string = params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),
       URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')
    binding.pry
    string_to_sign = "POST\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'),
                                                     ENV['SECRET_KEY'], string_to_sign)).strip
    request_url = "https://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature,
                                                                                                      Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
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
    {
      "ItemIds": asin,
      "PartnerTag": "savewhey-20",
      "PartnerType": "Associates",
      "Marketplace": "www.amazon.com.br",
      "Operation": "GetItems"
    }

    headers = {
      "Host": "webservices.amazon.com.br",
      "Accept": "application/json, text/javascript", 
      "X-Amz-Date": Time.now.gmtime.iso8601.gsub(/[^0-9a-z]/i, ''),
      "X-Amz-Target": "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetItems",
      "Content-Encoding": "amz-1.0"
    }
    generate_request_url(params)
  end
end
