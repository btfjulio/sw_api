class Suplemento < ApplicationRecord
  belongs_to :store
  has_many :sup_posts, dependent: :destroy
  has_many :prices, dependent: :destroy
  monetize :price_cents

  def create_price
    Price.create!(
        suplemento_id: self.id,
        price: self.price_cents
    )
    puts "price create for #{self.name}"
  end

  def prices_collection
    self.prices.pluck(:price)
  end

  def update_average
    average = self.prices.average(:price).to_i
    self.update!(
      average: average,
      diff: (self.price_cents - average) / self.price_cents
    )
    puts "average updated for #{self.name}"
  end

  def delete_old_prices(query)
    prices = self.prices.order(:created_at)
    while prices.count > 30
        prices.first(prices.size - 30).delete_all
        puts "old prices deleted for #{self.name}"
    end
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
  pg_search_scope :store_search,  
  associated_against:  { 
    store: :name 
    } ,
  using: {
    tsearch: { prefix: true }
  }
end
