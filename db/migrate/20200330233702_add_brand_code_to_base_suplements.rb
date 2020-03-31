class AddBrandCodeToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
      add_column :base_suplements, :brand_code, :string    
  end
end
