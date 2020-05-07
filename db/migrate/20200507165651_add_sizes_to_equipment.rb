class AddSizesToEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment, :sizes, :string    
  end
end
