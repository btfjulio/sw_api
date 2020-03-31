class AddLinkToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    add_column :base_suplements, :link, :string
  end
end
