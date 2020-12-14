class AddNormalizedNameToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :normalized_name, :string
  end
end
