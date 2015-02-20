class AddMonthAndYearToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :month, :string
    add_column :prices, :year, :integer
  end
end
