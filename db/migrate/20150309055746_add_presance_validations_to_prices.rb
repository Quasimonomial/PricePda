class AddPresanceValidationsToPrices < ActiveRecord::Migration
  def change
    change_column :prices, :product_id, :integer, null: false
    change_column :prices, :pricer_id, :integer, null: false
    change_column :prices, :pricer_type, :string, null: false
  end
end