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

