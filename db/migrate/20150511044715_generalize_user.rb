class GeneralizeUser < ActiveRecord::Migration
  def change
    rename_column :users, :hospital_name, :company_name
  end
end
