class Price < ApplicationRecord
  belongs_to :suplemento, optional: true
  belongs_to :equipment, optional: true
end
