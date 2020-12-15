class Brand < ApplicationRecord
  has_many :base_suplements
  include PgSearch::Model
  pg_search_scope :search_name, 
                against: [:search_name],
                using: {
                  tsearch: { prefix: true }
                }   
end