class AddPresanceValidationsToCompanies < ActiveRecord::Migration
  def change
    change_column :companies, :name, :string, null: false
    change_column :companies, :enabled, :boolean, null: false
  end
end
