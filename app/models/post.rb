class Post < ApplicationRecord
    belongs_to :suplemento, optional: true
end
