class AddDiffToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :diff , :integer
  end
end
