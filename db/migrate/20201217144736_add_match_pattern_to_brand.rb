class AddMatchPatternToBrand < ActiveRecord::Migration[5.2]
  def change
    add_column :brands, :match_pattern, :string
  end
end
