class Suplemento < ApplicationRecord
  belongs_to :store
  monetize :price_cents
  include PgSearch::Model
  pg_search_scope :sup_search,
  against: [:name, :seller, :brand, :promo],
  using: {
    tsearch: { prefix: true }
  }
end
