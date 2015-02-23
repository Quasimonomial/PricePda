class CreateHistoricalPrices < ActiveRecord::Migration
  def change
    create_table :historical_prices do |t|
      t.integer :price_id, null: false
      t.integer :month
      t.integer :year
      t.decimal precision: 7, scale: 2, null: false
    end
    add_index :historical_prices, :price_id
    add_index :historical_prices, :month
    add_index :historical_prices, :year

  end
end
