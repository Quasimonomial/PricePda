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
#  month       :string(255)
#  year        :integer
#

class Price < ActiveRecord::Base
  validates :price, :product_id, :pricer_id, :pricer_type, presence: true
  validates_uniqueness_of :product_id, scope: [:pricer_id, :pricer_type]

	belongs_to :pricer, :polymorphic => true
	belongs_to :product

  def self.process_product params, product, user
    products_hash = params.to_h
    prices = product.prices

    prices_hash = Hash.new #has the prices from our datavase

    prices.each do |price|
      #this hash is in the format company_id/user_id -> [price_id, price]

      if price.pricer_type == "Company"
      
        prices_hash[price.pricer_id] = [price.id, price.price]
      elsif price.pricer_type == "User" and price.pricer_id == user.id
        prices_hash["User"] = [price.id, price.price]
      end
    end

    company_name_hash = Company.build_name_hash

    set_vars = ["id", "name","category", "dosage", "package", "format", "action", "controller", "product"] #hardcode in some things I don't need    
    products_hash.each do |key, value|
      next if set_vars.include?(key)
      if key == "User" #special case if the user is updating thier price
        #if we have a user price in teh database see if it is updated
        if prices_hash.include?("User")
          unless value == prices_hash["User"][1]
            price_to_update = Price.find(prices_hash["User"][0])
            price_to_update.price = value
            price_to_update.save!
          end
        else#, create one
          new_price = Price.new({product_id: products_hash["id"], pricer_type: "User", pricer_id: user.id, price: value})
          p new_price
          new_price.save!
        end
      elsif !company_name_hash.include?(key)
        next # prices not related to a real company name are ignored
      elsif prices_hash.has_key?(company_name_hash[key])
        price_data = prices_hash[company_name_hash[key]]
        
        if value == price_data[1]
          puts "price match!" 
        else
          puts "Attempting to update price in database"
          price_to_update = Price.find(price_data[0])
          price_to_update.price = value
          price_to_update.save!
        end
      else #create new price if we don't jave a real company
        puts "Attempting to load in new price"
        new_price = Price.new({product_id: products_hash["id"], pricer_type: "Company", pricer_id: company_name_hash[key], price: value})
        p new_price
        new_price.save!
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
