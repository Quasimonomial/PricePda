# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  category   :string(255)
#  dosage     :string(255)
#  package    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#  enabled    :boolean
#
class Hash
  def self.recursive
    new { |hash, key| hash[key] = recursive }
  end
end

class Product < ActiveRecord::Base
  #add a uniqueness validation for a set of three or four feilds, ask ethan about this
  has_many :prices

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.import_from_excel file
    puts "Importing!"
    workbook = RubyXL::Parser.parse(file)

    worksheet = workbook[0]
    worksheet.get_table[:table].each do |product_attrs|
      this_id = product_attrs["ID"]
      if Product.exists?(this_id)
        product = Product.find(this_id)
      else
        product = Product.new
        product.id = this_id
      end
      
      product.category = product_attrs["Category"]
      product.name = product_attrs["Product"]
      product.dosage = product_attrs["Dosage"]
      product.package = product_attrs["Package"]
      product.save!
    end
  end


  def prices_array current_user
    @pricesArray = []
    @pricesForProduct = self.prices.includes(:pricer)

    @pricesForProduct.each do |price|
      next if price.pricer.nil?
      if price.pricer_type == "Company"
        @pricesArray << [price.pricer.name, price.price]
      #elsif price.pricer_type == "User" && price.pricer_id == user.id
        #@pricesArray << ["User", price.price]
      elsif price.pricer_type == "User" && price.pricer_id == current_user.id
        @pricesArray << ["User", price.price]
      end
    end
    return @pricesArray
  end

  def self.jsonify_all current_user
    @products = Product.all.order(:id)
    json_products = Jsonify::Builder.new(:format => :pretty)

    json_products.products(@products)do |product|
      json_products.id product.id
      json_products.category product.category
      json_products.dosage product.dosage
      json_products.package product.package
      json_products.name product.name
      json_products.enabled product.enabled
      product.prices_array(current_user).each do |price|
        json_products.tag!(price[0], price[1].to_f) 
      end
    end
    return json_products.compile!
  end

  def jsonify_this current_user #do I ever need to use this?
    json_product = Jsonify::Builder.new(:format => :pretty)
    json_product.id self.id
    json_product.category self.category
    json_product.dosage self.dosage
    json_product.package self.package
    json_product.name self.name
    json_product.enabled self.enabled
    self.prices_array(current_user).each do |price|
      json_product.tag!(price[0], price[1].to_f) 
    end

    return json_product.compile!
  end

  def generate_historical_hash
    companies = Company.all
    historical_pile = []
    historical_hash = Hash.recursive
    self.prices.where({pricer_type: "Company"}).each do |price|
      price.historical_prices.each do|historical_price|
        next unless historical_price.month && historical_price.year
        historical_hash[historical_price.year][historical_price.month][companies.find(price.pricer_id).name] = historical_price.price_value
      end
    end
    
    # historical_pile.each do |historical_price|
    #   historical_hash[{month: historical_price.month, year: historical_hash.year}] = historical_price.price
    # end
    historical_hash
  end

end
