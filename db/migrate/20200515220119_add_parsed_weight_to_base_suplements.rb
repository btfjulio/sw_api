class AddParsedWeightToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    add_column :base_suplements, :parsed_weight, :integer
  end
end
