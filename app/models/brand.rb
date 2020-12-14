class Brand < ApplicationRecord
  has_many :base_suplements
  include PgSearch::Model
  pg_search_scope :search_name, 
  against: [:search_name],
  using: {
    tsearch: { prefix: true }
  }

  pg_search_scope :search_name_trigram,
                against: [:search_name],
                using: {
                  trigram: {
                    threshold: 0.3
                  }
                }

                
end