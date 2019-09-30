class CreateSuplementos < ActiveRecord::Migration[5.2]
  def change
    create_table :suplementos do |t|
      t.string :name
      t.integer :price
      t.string :seller
      t.string :sender
      t.string :weight
      t.string :flavor
      t.references :store, foreign_key: true

      t.timestamps
    end
  end
end
