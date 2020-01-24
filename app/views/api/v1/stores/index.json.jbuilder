json.array! @stores do |store|
  json.extract! store, :name, :id
end