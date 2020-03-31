class AddCheckToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    add_column :base_suplements, :checked, :boolean, default: false
  end
end
