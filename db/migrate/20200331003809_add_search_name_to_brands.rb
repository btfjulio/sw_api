class AddSearchNameToBrands < ActiveRecord::Migration[5.2]
  def change
    add_column :brands, :search_name, :string
  end
end
