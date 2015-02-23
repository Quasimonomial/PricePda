class RemoveYearAndMonthFromPrices2 < ActiveRecord::Migration
  def change
    rename_column :prices, :month, :string
    rename_column :prices, :year, :integer
  end
end
