class Post < ApplicationRecord
    has_many :sup_posts, dependent: :destroy 
    has_many :suplementos, through: :sup_posts
end
