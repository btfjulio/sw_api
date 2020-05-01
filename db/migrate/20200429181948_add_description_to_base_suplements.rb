class AddDescriptionToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    add_column :base_suplements, :description, :string    
  end
end
