class CreateBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    create_table :base_suplements do |t|

      t.string :name
      t.string :photo
      t.string :store_code
      t.string :auxgrad
      t.string :category
      t.string :subcategory
      t.string :flavor
      t.string :ean
      t.references :brand, foreign_key: true
    end
  end
end


