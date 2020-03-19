desc 'Update Netshoes Stock'
task update_netshoes_stock: :environment do
    updater = NetshoesUpdater.new()
    updater.check_stock()
end

desc 'Update App Posts'
task update_posts: :environment do
    updater = PostsUpdater.new()
    updater.get_app_products()
end

STORES = [
    { id: 1, logo: 'amz-logo.png' },
    { id: 2, logo: 'net-logo.png' },
    { id: 3, logo: 'mw-logo.png' },
    { id: 4, logo: 'cp-logo.png' },
    { id: 5, logo: 'cent-logo.png' },
    { id: 6, logo: 'ci-logo.png' },
]

desc 'Populate stores pictures'
task update_stores_pictures: :environment do
    STORES.each do |store|
        db_store = Store.find(store[:id])
        db_store.logo = store[:logo]
        db_store.save
    end
end
