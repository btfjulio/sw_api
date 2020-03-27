class CreateSupPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :sup_posts do |t|
      t.references :suplemento, foreign_key: true
      t.references :post, foreign_key: true
      t.timestamps
    end
  end
end
