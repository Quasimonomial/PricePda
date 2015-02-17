class Addenabledtocompany < ActiveRecord::Migration
  def change
    add_column :companies, :enabled, :boolean
  end
end
