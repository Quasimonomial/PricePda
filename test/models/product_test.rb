# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  category   :string(255)
#  product    :string(255)
#  dosage     :string(255)
#  package    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
