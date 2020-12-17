class Suplemento < ApplicationRecord
  belongs_to :store
  belongs_to :brand, optional: true
  has_many :sup_posts, dependent: :destroy
  has_many :prices, dependent: :destroy
  monetize :price_cents

  before_save :parse_info

  def parse_info
    puts "parsing info..."
    normalize_name unless normalized_name?
    find_brand unless brand.present?
    parse_weight  unless weight?
  end

  def normalize_name 
    self.normalized_name = name.parameterize.gsub('-', '')
  end

  def find_brand
    found_brand = Brand.all.select { |brand| normalized_name.match(brand.search_name) }
    self.brand = found_brand&.first
  end

  def parse_weight
    pattern = /([0-9](,|.))?([0-9]){1,4}(\s?)(saches|barras|kg|lbs|lb|g|ml|tabs|tabletes|caps|cps|(unidade)s?)/i
    self.weight = self.normalized_name.match(pattern)
  end


  def self.calc_discount 
    self
      .pluck('*' , '((price_cents - average) / (average / 100)) as discount')
      .where('average > 0')
  end

  def create_price
    prices.build(
      price: price_cents
    )
    puts "price create for #{name}"
  end

  def prices_collection
    prices.pluck(:price)
  end

  def update_average
    average = prices.average(:price).to_i
    update!(
      average: average,
      diff: (price_cents - average) / price_cents
    )
    puts "average updated for #{name}"
  end

  def delete_old_prices
    prices.order(:created_at).limit(prices.size - 15).delete_all
    puts "old prices deleted for #{name}"
  end

  include PgSearch::Model
  pg_search_scope :search_brand,
                  against: [:brand],
                  using: {
                    tsearch: { prefix: true }
                  }

  pg_search_scope :search_store_code,
                  against: [:store_code],
                  using: {
                    tsearch: { prefix: true }
                  }
  # check where using this code
  pg_search_scope :search_brand_name,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }

  pg_search_scope :name_search,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }

  pg_search_scope :seller_search,
                  against: :seller,
                  using: {
                    tsearch: { prefix: true }
                  }
  
  pg_search_scope :find_related,
                  against: [:name],
                  using: :trigram


  def update_prices
    create_price
    delete_old_prices if prices.size > 15
    update_average
  end
end
