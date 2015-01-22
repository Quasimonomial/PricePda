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

  def self.process_product params, product
    products_hash = params.to_h
    prices = product.prices

    prices_hash = Hash.new

    prices.each do |price|
      next unless price.pricer_type == "Company"
      #this hash is in the format company_id -> [price_id, price]
      prices_hash[price.pricer_id] = [price.id, price.price]
    end
    puts "Price Hash Here"
    puts prices_hash
    # puts "Processing Product"
    # puts prices
    # puts "Prices:"
    # prices.each do |price|
    #   p price
    # end

    company_name_hash = Company.build_name_hash

    set_vars = ["id", "name","category", "dosage", "package", "format", "action", "controller", "product"] #hardcode in some things I don't need    
    products_hash.each do |key, value|
      next if set_vars.include?(key)
      # puts "doing crazy shit"
      # p prices.where(pricer: "Company", pricer_id: company_name_hash[key]).first
      if prices_hash.has_key?(company_name_hash[key])
        price_data = prices_hash[company_name_hash[key]]

        puts "Key Found!"
        puts key
        puts "Price incoming"
        puts value
        puts "Price Old"
        puts price_data[1]
        
        puts "price match!" if value == price_data[1]
      end

    end
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
