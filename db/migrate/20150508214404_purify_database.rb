class PurifyDatabase < ActiveRecord::Migration
  def change
    remove_column :products, :package, :string
    rename_column :products, :dosage, :manufacturer
  end
end
