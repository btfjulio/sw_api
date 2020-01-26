json.stores do
  json.array! @stores do |store|
    json.extract! store, :name, :id
  end
end

json.sellers do
  json.array! @sellers do |seller|
    json.extract! seller, :seller
  end
end
