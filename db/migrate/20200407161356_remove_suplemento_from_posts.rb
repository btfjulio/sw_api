class RemoveSuplementoFromPosts < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :suplemento_id
  end
end
