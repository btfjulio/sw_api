class CreateSuplementos < ActiveRecord::Migration[5.2]
  def change
    create_table :suplementos do |t|
      t.string :name
      t.string :link
      t.string :seller
      t.string :sender
      t.string :weight
      t.string :flavor
      t.string :store_code
      t.boolean :price_changed?
      t.string :brand
      t.references :store, foreign_key: true
      t.timestamps
    end
  end
end
