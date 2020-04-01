class BaseSuplementSerializer < ActiveModel::Serializer
  attributes :name, :category, :subcategory, :flavor, :ean, :weight
  belongs_to :brand
  has_many :sup_photos
  def attributes(*args)
    base_suplement = super(*args)
    base_suplement[:name] = object.name[0..((object.name =~ /\(/) - 1)].strip.titleize
    base_suplement
  end

end
