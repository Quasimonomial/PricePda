class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer  :price #in cents
      t.integer :product_id
      t.integer :pricer_id
      t.string  :pricer_type

      t.timestamps
    end
  end
end
