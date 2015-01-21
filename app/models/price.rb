# == Schema Information
#
# Table name: prices
#
#  id          :integer          not null, primary key
#  price       :integer
#  product_id  :integer
#  pricer_id   :integer
#  pricer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Price < ActiveRecord::Base
  validates_uniqueness_of :product_id, scope: [:pricer_id, :pricer_type]

	belongs_to :pricer, :polymorphic => true
	belongs_to :product

  def self.process_product product
    puts "Processing Product"
    puts product
  end

	def ouside_price_range?(user)
    user_price_obj = user.prices.where(product_id: self.product_id).first
    return false unless user_price_obj
    user_price = user_price_obj.price
    puts user_price
    puts (((user_price - self.price) *1.0) * 100/user_price)
    puts user.price_range_percentage
    (((user_price - self.price) *1.0) * 100/user_price) >= user.price_range_percentage
  end
end
