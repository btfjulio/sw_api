class CreateBrandVariations < ActiveRecord::Migration[5.2]
  def change
    create_table :brand_variations do |t|
      t.string :name
      t.references :brand, foreign_key: true
      t.timestamps
    end
  end
end
