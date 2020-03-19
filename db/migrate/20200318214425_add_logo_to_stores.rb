class AddLogoToStores < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :logo, :string
  end
end
