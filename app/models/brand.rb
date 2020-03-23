class Brand < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_name, 
  against: [:name],
  using: {
    tsearch: { prefix: true }
  }
end