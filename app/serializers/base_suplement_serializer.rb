class BaseSuplementSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :subcategory, :flavor, :ean, :weight
  belongs_to :brand
  has_many :sup_photos
  def attributes(*args)
    base_suplement = super(*args)
    base_suplement
  end

end
