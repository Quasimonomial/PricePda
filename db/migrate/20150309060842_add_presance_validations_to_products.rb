class AddPresanceValidationsToProducts < ActiveRecord::Migration
  def change
    change_column :products, :category, :string, null: false
    change_column :products, :name, :string, null: false
    change_column :products, :enabled, :boolean, null: false
  end
end