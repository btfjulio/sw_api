json.array! @suplementos do |suplemento|
  json.extract! suplemento, :id, :name, :asin
end