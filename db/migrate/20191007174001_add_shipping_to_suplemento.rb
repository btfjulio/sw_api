class AddShippingToSuplemento < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :prime , :boolean
    add_column :suplementos, :supershipping , :boolean
  end
end
