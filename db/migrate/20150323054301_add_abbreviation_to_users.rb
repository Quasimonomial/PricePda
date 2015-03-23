class AddAbbreviationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :abbreviation, :string
  end
end
