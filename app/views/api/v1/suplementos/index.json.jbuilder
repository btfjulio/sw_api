json.array! @suplementos do |suplemento|
  json.extract! suplemento, :id, :name, :photo, :store_code, :link, 
    :weight, :flavor, :brand, :price
end