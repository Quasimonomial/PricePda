class AddPriceToHistoricalPrices < ActiveRecord::Migration
  def change
    add_column :historical_prices, :price, :decimal, precision: 7, scale: 2, null: false
  end
end
