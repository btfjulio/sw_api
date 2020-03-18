class AddColumnsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :updated, :boolean, default: false
    add_column :posts, :online, :boolean, default: false
  end
end
