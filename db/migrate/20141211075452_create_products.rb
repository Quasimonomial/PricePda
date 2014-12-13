class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :category
      t.string :product
      t.string :dosage
      t.string :package

      t.timestamps
    end

    add_index :products, :category
    add_index :products, :product
    add_index :products, :dosage
    add_index :products, :package
  end
end
