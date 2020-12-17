class Brand < ApplicationRecord
  has_many :base_suplements
  before_create :add_match_pattern

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
                    threshold: 0.5
                  }
                }

  def add_match_pattern
    self.match_pattern = self.search_name
  end

                
end