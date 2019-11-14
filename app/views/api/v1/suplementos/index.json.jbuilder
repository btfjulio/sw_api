json.array! @headers

json.array! @suplementos do |suplemento|
  json.extract! suplemento, :id, :store_id, :name, :photo, :seller, :store_code, :link, 
    :weight, :flavor, :brand, :price_changed, :price, :average, :diff, :prime, :supershipping, :promo, :updated_at, :created_at
end