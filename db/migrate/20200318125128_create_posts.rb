class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|

      t.string :title
      t.string :img
      t.string :coupon
      t.string :link
      t.integer :clicks
      t.references :suplemento, foreign_key: true
      t.timestamps
    end
  end
end
