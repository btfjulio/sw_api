class AddClicksToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :last_day_clicks, :integer, default: 0
  end
end
