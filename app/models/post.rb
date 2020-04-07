class Post < ApplicationRecord
    belongs_to :suplemento, optional: true
    has_many :sup_posts, dependent: :destroy 
    has_many :suplementos, through: :sup_posts
end
