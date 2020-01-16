desc 'Update Netshoes Stock'
task update_netshoes_stock: :environment do
    updater = NetshoesUpdater.new()
    updater.check_stock()
end