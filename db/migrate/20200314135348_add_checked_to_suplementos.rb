class AddCheckedToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :checked, :boolean, default: false
  end
end
