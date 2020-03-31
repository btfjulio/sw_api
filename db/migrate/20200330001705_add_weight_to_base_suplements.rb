class AddWeightToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
   add_column :base_suplements, :weight, :string   
  end
end
