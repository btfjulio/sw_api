class Post < ApplicationRecord
    belongs_to :suplemento, optional: true
    has_many :sup_posts
end
