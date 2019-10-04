class AddPhotoToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :photo, :string
  end
end
