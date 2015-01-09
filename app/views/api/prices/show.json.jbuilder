json.extract! @price, :id, :price, :product_id, :pricer_id, :pricer_type, :created_at


#  id          :integer          not null, primary key
#  price       :integer
#  product_id  :integer
#  pricer_id   :integer
#  pricer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime