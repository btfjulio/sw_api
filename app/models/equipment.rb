class Equipment < ApplicationRecord
    belongs_to :store
    has_many :prices, dependent: :destroy
    
  def create_price
    Price.create!(
        equipment_id: self.id,
        price: self.price
    )
    puts "price create for #{self.name}"
  end

  def prices_collection
    self.prices.pluck(:price)
  end

  def update_average
    average = self.prices.average(:price).to_i
    self.update!(
      average: average
    )
    puts "average updated for #{self.name}"
  end

  def delete_old_prices(query)
    prices = self.prices.order(:created_at)
    while prices.size > 30
        prices.limit(prices.size - 30).delete_all
        puts "old prices deleted for #{self.name}"
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
