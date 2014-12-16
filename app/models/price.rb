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
	belongs_to :pricer, :polymorphic => true
	belongs_to :product

	def in_price_range?(user)

  end
end
