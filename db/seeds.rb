stores = [
  {
    name: 'Amazon',
    logo: 'amz-logo.png'
  },
  {
    name: 'Netshoes',
    logo: 'net-logo.png'
  },
  {
    name: 'Musculos na Web',
    logo: 'mw-logo.png'
  },
  {
    name: 'Corpo Ideal',
    logo: 'ci-logo.png'
  },
  {
    name: 'Corpo Perfeito',
    logo: 'cp-logo.png'
  },
  {
    name: 'Centauro',
    logo: 'cent-logo.png'
  }
]

stores.each do |store|
  new_store = Store.create(store)
  puts "Criada loja #{new_store.name}"
end