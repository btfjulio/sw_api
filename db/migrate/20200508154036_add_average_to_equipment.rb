class AddAverageToEquipment < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment, :average, :integer    
  end
end
