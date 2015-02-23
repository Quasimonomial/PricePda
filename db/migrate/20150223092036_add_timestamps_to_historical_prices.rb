class AddTimestampsToHistoricalPrices < ActiveRecord::Migration
  def change
      add_column(:historical_prices, :created_at, :datetime)
      add_column(:historical_prices, :updated_at, :datetime)
  end
end
