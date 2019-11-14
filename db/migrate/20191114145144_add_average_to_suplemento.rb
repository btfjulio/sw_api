class AddAverageToSuplemento < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :average , :integer
  end
end
