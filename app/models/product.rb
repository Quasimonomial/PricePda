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

class Product < ActiveRecord::Base
  #add a uniqueness validation for a set of three or four feilds, ask ethan about this
end
