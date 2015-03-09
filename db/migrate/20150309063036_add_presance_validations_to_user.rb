class AddPresanceValidationsToUser < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, null: false
    change_column :users, :password_digest, :string, null: false
    change_column :users, :first_name, :string, null: false
    change_column :users, :last_name, :string, null: false
    change_column :users, :hospital_name, :string, null: false
    change_column :users, :city, :string, null: false
    change_column :users, :state, :string, null: false
    change_column :users, :zip_code, :string, null: false
  end
end
