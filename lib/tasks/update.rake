
# check if netshoes products are available - needs improvement
desc 'Update Netshoes Stock'
task update_netshoes_stock: :environment do
    updater = NetshoesUpdater.new()
    updater.check_stock()
end


# get posts app informations
desc 'Update App Posts'
task update_posts: :environment do
    updater = PostsUpdater.new()
    updater.get_app_products()
end

# task to measure daily clicks on posts
desc 'Update App Posts'
task update_last_day_clicks: :environment do
    Post.all.each do |post|
        if post.clicks
            post.update(last_day_clicks: post.clicks)
        end
    end
end


# stores images seed
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

# brands first seed - got same list as Saudi Products 
desc 'Populate stores pictures'
task create_brands: :environment do
    Suplemento.where(store_id: 6).each do |suplemento|
        unless ( suplemento.brand_code == "" || suplemento.brand_code.nil? )
            b = Brand.find_or_create_by({
                store_code: suplemento.brand_code,
                logo: "https://resources.saudifitness.com.br/resources/img/fabricante/#{suplemento.brand_code}.gif",
                name: suplemento.brand
            })
        end
        puts "Brand #{b.name} saved on db"
    end
end


# using string methods to match brand in scraped products
desc 'Populate brand codes'
task update_brand_codes: :environment do

    def match_brands(collection, brand)
        puts brand.name
        puts collection
        collection.each do |product|
            product.update({
                brand_code: brand.store_code
            })     
            puts "Brand #{product.name} saved on with brand #{brand.name} db"
        end
    end

    Brand.all.each do |brand|
        strings = [
            brand.name,
            I18n.transliterate(brand.name),
            I18n.transliterate(brand.name.split(' ').join()),
            brand.name.split(' ').join()
        ].uniq
        puts strings
        strings.each do |string|
            puts "Try match string #{string}"
            collection = Suplemento.where(brand: brand.name, brand_code: nil)
            match_brands(collection, brand)
            collection = Suplemento.where(brand_code: nil).search_brand(string) 
            match_brands(collection, brand)
            collection = Suplemento.where(brand_code: nil).search_brand_name(string) 
            match_brands(collection, brand)     
        end
    end
    
end
