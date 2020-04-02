class CategorySerializer < ActiveModel::Serializer
  attributes :name
  has_many :subcategories, key: "subcategories_attributes"
end