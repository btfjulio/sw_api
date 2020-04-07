class SupPost < ApplicationRecord
    belongs_to :suplemento, dependet: :destroy
    belongs_to :post
end
