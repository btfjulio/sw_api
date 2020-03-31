class CreateSupPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :sup_photos do |t|
      t.string :url
      t.string :name
      t.string :size
      t.references :base_suplement, foreign_key: true
      t.timestamps
    end
  end
end
