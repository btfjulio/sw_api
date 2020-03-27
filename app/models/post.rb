class Post < ApplicationRecord
    belongs_to :suplemento, optional: true
    has_many :sup_posts
    has_many :suplementos, through: :sup_posts
end
