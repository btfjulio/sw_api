class Suplemento < ApplicationRecord
  belongs_to :store
  has_many :prices, dependent: :destroy
  monetize :price_cents


  def as_json(options={})
    super(
      root: true
    )
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
