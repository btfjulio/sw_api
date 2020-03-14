class AddAuxToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :auxgrad, :integer
  end
end
