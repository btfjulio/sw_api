
class AmazonApi
  def initialize()
    @resources = set_resources()
    @api = Vacuum.new(
      marketplace: 'br',
      access_key: ENV['AMAZON_ID'],
      secret_key: ENV['SECRET_KEY'],
      partner_tag: 'savewhey-20'
    )
  end

  def get_products(items_ids)
    begin
      response = @api.get_items(
        item_ids: items_ids,
        resources: @resources
      ).to_h  
      response["ItemsResult"]["Items"]
    rescue => exception
      binding.pry
    end
  end

  def set_resources
    [ 
      'BrowseNodeInfo.BrowseNodes',
      'Images.Primary.Medium', 
      'ItemInfo.ByLineInfo',
      'ItemInfo.ContentInfo', 
      'ItemInfo.ExternalIds', 
      'ItemInfo.TechnicalInfo', 
      'ItemInfo.Title', 
      'ItemInfo.Features', 
      'ItemInfo.ManufactureInfo',
      'ItemInfo.ProductInfo', 
      'Offers.Listings.Price',
      'Offers.Listings.DeliveryInfo.IsFreeShippingEligible',
      'Offers.Listings.DeliveryInfo.IsPrimeEligible',
      'Offers.Listings.MerchantInfo'
    ]
  end

end

