class AddOriginsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, not_null: true
    add_column :users, :last_name, :string, not_null: true
    add_column :users, :hospital_name, :string, not_null: true
    add_column :users, :city, :string, not_null: true
    add_column :users, :state, :string, not_null: true
    add_column :users, :zip_code, :string, not_null: true
    add_column :users, :phone, :string
  end
end
