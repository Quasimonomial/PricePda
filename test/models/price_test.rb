# == Schema Information
#
# Table name: prices
#
#  id          :integer          not null, primary key
#  price       :decimal(7, 2)    not null
#  product_id  :integer          not null
#  pricer_id   :integer          not null
#  pricer_type :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
