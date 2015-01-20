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

  def buildPricesArray
    @pricesArray = []
    companies = Company.all
    self.prices.each do |price|
      if price.pricer_type == "Company" && !price.pricer.nil?
        puts "Price Found!!"
        puts price.pricer.name
        puts price.price
        @pricesArray << [price.pricer.name, price.price]
      else
        puts "Company Does not exist"
      end
    end
    return @pricesArray
  end
end
