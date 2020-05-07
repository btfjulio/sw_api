class Equipment < ApplicationRecord
    belongs_to :store

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
