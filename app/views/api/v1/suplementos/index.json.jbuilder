json.array! @headers

json.array! @suplementos do |suplemento|
  json.extract! suplemento, :id, :store_id, :name, :photo, :seller, :store_code, :link, 
    :weight, :flavor, :brand, :price_changed, :price, :prime, :supershipping, :promo, :updated_at, :created_at
  json.prices   suplemento.prices.map do |price| 
    json.extract! price, :price, :created_at
  end
end