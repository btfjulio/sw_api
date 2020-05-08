class AddEquipmentsToPrices < ActiveRecord::Migration[5.2]
  def change
    add_reference :prices, :equipment, foreign_key: true
  end
end
