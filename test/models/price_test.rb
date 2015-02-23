# == Schema Information
#
# Table name: prices
#
#  id          :integer          not null, primary key
#  price       :decimal(7, 2)    not null
#  product_id  :integer
#  pricer_id   :integer
#  pricer_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  string      :string(255)
#  integer     :integer
#

require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
