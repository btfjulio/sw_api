json.array! @suplementos do |suplemento|
  json.extract! suplemento, :id, :store_id, :name, :photo, :seller, :store_code, :link, 
    :weight, :flavor, :brand, :price_changed, :price, :prime, :supershipping, :updated_at, :created_at
end