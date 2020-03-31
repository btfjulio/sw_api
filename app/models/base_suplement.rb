class BaseSuplement < ApplicationRecord
    belongs_to :brand, optional: true
    has_many :sup_photos, dependent: :destroy 
    accepts_nested_attributes_for :sup_photos
end
