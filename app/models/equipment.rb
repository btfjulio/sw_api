class Equipment < ApplicationRecord
  belongs_to :store
  has_many :prices, dependent: :destroy

  def create_price
    Price.create!(
      equipment_id: id,
      price: price
    )
    puts "price create for #{name}"
  end

  def prices_collection
    prices.pluck(:price)
  end

  def update_average
    average = prices.average(:price).to_i
    update!(
      average: average
    )
    puts "average updated for #{name}"
  end

  def delete_old_prices
    prices = self.prices.order(:created_at)
    while prices.size > 30
      prices.limit(prices.size - 30).delete_all
      puts "old prices deleted for #{name}"
    end
  end

  include PgSearch::Model
  pg_search_scope :seller_search,
                  against: :seller,
                  using: {
                    tsearch: { prefix: true }
                  }
  pg_search_scope :name_search,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }
end
