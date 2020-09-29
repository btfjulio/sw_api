class Suplemento < ApplicationRecord
  belongs_to :store
  has_many :sup_posts, dependent: :destroy
  has_many :prices, dependent: :destroy
  monetize :price_cents

  def create_price
    Price.create!(
      suplemento_id: id,
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
    prices = self.prices.order(:created_at)
    while prices.count > 30
      prices.limit(prices.size - 30).delete_all
      puts "old prices deleted for #{name}"
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
                  associated_against: {
                    store: :name
                  },
                  using: {
                    tsearch: { prefix: true }
                  }
end
