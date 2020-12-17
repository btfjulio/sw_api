class ChangeBrandToBeReferencesInSuplementos < ActiveRecord::Migration[5.2]
  def change
    remove_column :suplementos, :brand
    add_reference :suplementos, :brand, foreign_key: true
  end
end
