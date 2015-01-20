# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  category   :string(255)
#  name    :string(255)
#  dosage     :string(255)
#  package    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Product < ActiveRecord::Base
  #add a uniqueness validation for a set of three or four feilds, ask ethan about this
  has_many :prices

  attr_accessor :pricesArray

  def buildPricesArray(user = {id:-1})
    @pricesArray = []
    @pricesForProduct = self.prices.includes(:pricer)

    @pricesForProduct.each do |price|
      next if price.pricer.nil?
      if price.pricer_type == "Company"
        puts "Price Found!!"
        puts price.pricer.name
        puts price.price
        @pricesArray << [price.pricer.name, price.price]
      elsif user && price.pricer_type == "User" && price.pricer_id == user.id
        @pricesArray << ["User", price.price]
      end
    end
    return @pricesArray
  end
end
