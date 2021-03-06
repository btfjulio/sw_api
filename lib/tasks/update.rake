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
        store: 'lojacorpoperfeito',
        store_code: 'cp'
    })
    bs.access_api()
end

desc 'Collect Sups extra infos'
task collect_sup_extra_infos: :environment do
    BaseExtraInfoScraper.new({
        store: 'lojacorpoperfeito',
        store_code: 'cp'
    }).get_product_infos()
end

desc 'Collect Sups Description infos'
task collect_sup_description_infos: :environment do
    BaseSuplement.all.each do |product|
        if product.description.nil?
            BaseDescriptionScraper.new({
                product: product
            }).get_product_infos()
        end
    end
end

desc 'Unify products by name'
task match_products_name: :environment do
    def parse_name(product)
        split_index = product.name =~ /(\(|\s-\s)/
        if split_index
            product.name[0..(split_index - 1)].strip
        else
            product.name
        end
    end

    def find_matches(product, product_code)
        product_name = parse_name(product)
        brand_matches = BaseSuplement.where(brand_name: product.brand_name)
        matches = brand_matches.where("name LIKE ?", "%#{product_name}%")
        matches.each do |match| 
            match.update!(product_code: product_code) unless match.product_code.present? 
            puts "#{match.name} - #{match.weight} - #{product_code}"
        end
    end
    
    BaseSuplement.update_all(product_code: nil)
    product_code = 1
    
    BaseSuplement.all.each do |product|
        if product.product_code.blank?
            product.update!(product_code: product_code) 
            puts "#{product.name} - #{product.weight} - #{product_code}"
            matches = find_matches(product, product_code)
            product_code += 1
        end
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
                    search_name: I18n.transliterate(brand[0].gsub(" ", "").downcase).gsub(/(nutrition|research)/, '')
                })
            puts "Brand #{db_brand.name} updated on db"
        else
            b = Brand.create({
                    store_code: brand[1],
                    logo: convert_image(brand[1]),
                    name: brand[0],
                    search_name: I18n.transliterate(brand[0].gsub(" ", "").downcase).gsub(/(nutrition|research)/, '')
                })
            puts "NEW Brand #{b.name} created on db"
        end
    end


end

# brands first seed - got same list as Saudi Products 
desc 'Populate stores pictures'
task update_categories: :environment do

    categories = BaseSuplement.pluck(:category, :subcategory).uniq
    categories.each do |(category, subcategory)|
        db_category = Category.where(name: category)
        if db_category.empty?
            subcategories = categories.map {|(key, pair)| {name: pair} if key == category}
            subcategories.filter! {|subcat| !subcat.nil?}
            c = Category.create!({
                name: category,
                subcategories_attributes: subcategories
            })
            puts "#{c.name} created on DB"
        else
            puts "#{db_category.name} already exist on DB"
        end
    end

end


# brands first seed - got same list as Saudi Products 
desc 'Populate stores pictures'
task parse_weight: :environment do

    def find_weight(weight_string)
        weight_string.match(/\d,?\d{0,3}/).to_s.gsub(',','.').to_f
    end
    
    def find_caps(weight_string)
        pattern = /(?<caps>\d,?\d{0,3})-?((tabs?)|(comp)|(softgels?)|(caps))/
        match = weight_string.parameterize.match(pattern)
        match[:caps].to_i
    end

    BaseSuplement.all.each do |suplement| 
        parsed_weight = suplement.weight.downcase.gsub(/\s|refil/,'') 
        weight = suplement.weight
        case suplement.weight_pattern 
        when 'wl' then suplement.update(parsed_weight: suplement.weight_list)
        when 'kg' then suplement.update(parsed_weight: (find_weight(weight) * 1000).to_i) 
        when 'lb' then suplement.update(parsed_weight: (find_weight(weight) * 453.5).to_i) 
        when 'g' then suplement.update(parsed_weight: find_weight(weight))
        when 'shaker' then suplement.update(parsed_weight: 200)
        when 'ml' then suplement.update(parsed_weight: (find_weight(weight) * 1.5).to_i)
        when 'caps' then suplement.update(parsed_weight: find_caps(weight) * 2)
        when 'clothe' then suplement.update(parsed_weight: 200)
        when 'pack' then suplement.update(parsed_weight: (find_weight(weight) * 20).to_i)
        when 'gel' then suplement.update(parsed_weight: (find_weight(weight) * 20).to_i)
        when 'bar' then suplement.update(parsed_weight: (find_weight(weight) * 80).to_i)
        else suplement.destroy
        end
    end

end
