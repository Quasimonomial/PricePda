class RemoveStringAndIntegerFromPrices < ActiveRecord::Migration
  def change
    remove_column :prices, :string, :string
    remove_column :prices, :integer, :integer
  end
end
