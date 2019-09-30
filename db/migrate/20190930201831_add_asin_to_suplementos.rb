class AddAsinToSuplementos < ActiveRecord::Migration[5.2]
  def change
      add_column :suplementos, :asin, :string
  end
end
