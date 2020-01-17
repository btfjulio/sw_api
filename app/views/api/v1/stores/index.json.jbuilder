json.array! @stores do |store|
  json.extract! store, :name
end