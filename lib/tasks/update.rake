require 'open-uri'
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

    def convert_image(brand_code)
        image_address = "https://resources.saudifitness.com.br/resources/img/fabricante/#{brand_code}.gif"
        if Rails.env.production? 
            begin
                URI.open(image_address)
                uploaded_image = Cloudinary::Uploader.upload(image_address)
                return uploaded_image["secure_url"]    
            rescue => exception
                return nil
            end
        else
            return image_address
        end
    end


    brands = BaseSuplement.pluck(:brand_name, :brand_code).uniq
    brands.each do |brand|
        db_brand = Brand.where(store_code: brand[1]).first
        if db_brand
            db_brand.update({
                    store_code: brand[1],
                    logo: (db_brand.logo && db_brand.logo.match(/save-whey/)) ? db_brand.logo : convert_image(brand[1]),
                    name: brand[0],
                    search_name: brand[0].gsub(" ", "").downcase
                })
            puts "Brand #{db_brand.name} updated on db"
        else
            b = Brand.create({
                    store_code: brand[1],
                    logo: convert_image(brand[1]),
                    name: brand[0],
                    search_name: brand[0].gsub(" ", "").downcase
                })
            puts "NEW Brand #{b.name} created on db"
        end
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

#base supps info enrichment 

desc 'Collect Sups info'
task collect_sup_infos: :environment do
    bs = BaseSupsScraper.new({
        store: 'corpoidealsuplementos',
        store_code: 'ci'
    })
    bs.access_api()
end

desc 'Collect Sups extra infos'
task collect_sup_extra_infos: :environment do
    bs = BaseExtraInfoScraper.new({
        store: 'corpoidealsuplementos',
        store_code: 'ci'
    })
    bs.get_product_infos()
end
