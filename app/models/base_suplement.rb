class BaseSuplement < ApplicationRecord
    belongs_to :brand, optional: true
    has_many :sup_photos, dependent: :destroy 
    accepts_nested_attributes_for :sup_photos

    include PgSearch::Model
    pg_search_scope :name_search,
    against: :name,
    using: {
        tsearch: { prefix: true }
    }
end
