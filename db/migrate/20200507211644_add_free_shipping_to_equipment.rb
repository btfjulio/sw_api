class AddFreeShippingToEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment, :free_shipping, :boolean    
  end
end
