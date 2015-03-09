class AddIndexesToPriceColumns < ActiveRecord::Migration
  def change
    add_index :prices, :product_id
    add_index :prices, [:pricer_id, :pricer_type]
  end
end
