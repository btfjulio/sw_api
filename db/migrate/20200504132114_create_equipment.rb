class CreateEquipment < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment do |t|
      t.string :name
      t.string :link
      t.string :seller
      t.string :sender
      t.string :store_code
      t.string :photo
      t.string :category
      t.string :freeshipping
      t.string :brand
      t.references :store, foreign_key: true
      t.timestamps
    end
  end
end
