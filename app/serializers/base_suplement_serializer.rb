class BaseSuplementSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :subcategory, :flavor, :ean, :weight, :parsed_weight
  belongs_to :brand
  #  has_many :sup_photos
  def attributes(*args)
    base_suplement = super(*args)
    base_suplement[:name] = serialize_name(object.name)
    base_suplement[:product_photos_attributes] = exclude_fields(object.sup_photos)
    base_suplement
  end

  def serialize_name(product_name)
    index = product_name =~ /\(/
    if index
      product_name = product_name[0..((product_name =~ /\(/) - 1)]
    end
    product_name.strip.titleize
  end

  def exclude_fields(photos)
    photos.map { |photo| photo.slice(:name, :size, :url) }
  end

end
