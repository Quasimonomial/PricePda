class RenameHistoricalPricesPriceToPriceValue < ActiveRecord::Migration
  def change
    rename_column :historical_prices, :price, :price_value
  end
end
