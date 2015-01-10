class RemoveProductsFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :product, :string
    add_column :products, :name, :string
  end
end
