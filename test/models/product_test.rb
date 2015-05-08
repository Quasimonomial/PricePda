# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  category     :string(255)      not null
#  manufacturer :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  name         :string(255)      not null
#  enabled      :boolean          not null
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
