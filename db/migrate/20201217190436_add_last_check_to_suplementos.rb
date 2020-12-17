class AddLastCheckToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :last_check, :datetime
  end
end
