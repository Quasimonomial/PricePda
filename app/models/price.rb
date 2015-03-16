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
#

class Price < ActiveRecord::Base
  validates :price, :product_id, :pricer_id, :pricer_type, presence: true
  validates_uniqueness_of :product_id, scope: [:pricer_id, :pricer_type]

	belongs_to :pricer, :polymorphic => true
	belongs_to :product
  has_many :historical_prices

  def self.import_company_from_excel file, month, year
    puts "Importing!"
    company_name_hash = Company.build_name_hash
    workbook = RubyXL::Parser.parse(file)
    puts "HELLO TO HEROKU"
    prices = Price.where({pricer_type: "Company"})

    worksheet = workbook[0]
    worksheet.get_table[:table].each do |price_attrs|
      price_attrs.each do|key, value|
        next unless company_name_hash[key]
        price = Price.where({pricer_type: "Company", pricer_id: company_name_hash[key], product_id: price_attrs["ID"]}).first

        unless price
          price = Price.new
          price.pricer_type = "Company"
          price.pricer_id = company_name_hash[key]
          price.product_id = price_attrs["ID"]
        end
        price.price = value 
        price.save!
        price.create_historical_price_by_time month, year
      end
    end
  end

  def self.import_user_from_excel file, current_user
    puts "Importing!"

    workbook = RubyXL::Parser.parse(file)

    prices = Price.where({pricer_type: "User", pricer_id: current_user.id})

    worksheet = workbook[0]

    worksheet.get_table[:table].each do |price_attrs|
      if price_attrs["Price"]


        price = Price.where({pricer_type: "User", pricer_id: current_user.id, product_id: price_attrs["ID"]}).first

        unless price
          price = Price.new
          price.pricer_type = "User"
          price.pricer_id = current_user.id
          price.product_id = price_attrs["ID"]
        end
        price.price = price_attrs["Price"] 
        
        price.save!
        price.create_historical_price
      end
    end
  end

  def self.process_product params, product, user
    puts "PROCESSING PRODUCT"
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
            price_to_update.create_historical_price
          end
        else#, create one
          new_price = Price.new({product_id: products_hash["id"], pricer_type: "User", pricer_id: user.id, price: value})
          p new_price
          new_price.save!
          new_price.create_historical_price
        end
      elsif !company_name_hash.include?(key)
        next # prices not related to a real company name are ignored
      elsif prices_hash.has_key?(company_name_hash[key])
        next unless user.is_admin

        price_data = prices_hash[company_name_hash[key]]
        
        if value == price_data[1]
          puts "price match!" 
        else
          puts "Attempting to update price in database"
          price_to_update = Price.find(price_data[0])
          price_to_update.price = value
          price_to_update.save!
          price_to_update.create_historical_price
        end
      else #create new price if we don't jave a real company
        puts "Attempting to load in new price"
        new_price = Price.new({product_id: products_hash["id"], pricer_type: "Company", pricer_id: company_name_hash[key], price: value})
        p new_price
        new_price.save!
        new_price.create_historical_price
      end

    end
  end

  def create_historical_price
    # this should be run whenever we want to create a new price in the database
    # note convention is that when we update a price, we create a new historical price from the new price we are saving, not from the previous price
    historical = HistoricalPrice.new()
    historical.price_id = self.id
    historical.price_value = self.price
    historical.save()
    historical.assign_month_and_year
  end

  def create_historical_price_by_time month, year
    historical = HistoricalPrice.new()
    historical.price_id = self.id
    historical.price_value = self.price
    historical.save
    historical.assign_custom_month_and_year month, year
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
