class AddDependantsToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :dependants, :integer, default: 0
  end
end
