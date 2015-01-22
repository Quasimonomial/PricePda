class ChancePricesToDecimal < ActiveRecord::Migration
  def change
    change_column :prices, :price, :decimal, precision: 7, scale: 2, null: false
  end
end
