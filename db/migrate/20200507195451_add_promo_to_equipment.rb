class AddPromoToEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment, :promo, :string    
  end
end
