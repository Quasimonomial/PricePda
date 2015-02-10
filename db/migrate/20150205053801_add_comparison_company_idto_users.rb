class AddComparisonCompanyIdtoUsers < ActiveRecord::Migration
  def change
    add_column :users, :comparison_company_id, :integer
  end
end
