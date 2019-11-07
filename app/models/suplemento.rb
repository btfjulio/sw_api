class Suplemento < ApplicationRecord
  belongs_to :store
  monetize :price_cents
  include PgSearch::Model
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
