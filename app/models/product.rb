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

  # attr_accessor :pricesArray



  def prices_array
    @pricesArray = []
    @pricesForProduct = self.prices.includes(:pricer)

    @pricesForProduct.each do |price|
      next if price.pricer.nil?
      if price.pricer_type == "Company"
        @pricesArray << [price.pricer.name, price.price]
      #elsif price.pricer_type == "User" && price.pricer_id == user.id
        #@pricesArray << ["User", price.price]
      end
    end
    return @pricesArray
  end

  def self.jsonify_all
    @products = Product.all
    json_products = Jsonify::Builder.new(:format => :pretty)

    json_products.products(@products)do |product|
      json_products.id product.id
      json_products.category product.category
      json_products.dosage product.dosage
      json_products.package product.package
      json_products.name product.name
      product.prices_array.each do |price|
        json_products.tag!(price[0], price[1]) 
      end
    end
    return json_products.compile!
  end

  def jsonify_this
    json_product = Jsonify::Builder.new(:format => :pretty)
    json_product.id self.id
    json_product.category self.category
    json_product.dosage self.dosage
    json_product.package self.package
    json_product.name self.name
    self.prices_array.each do |price|
      json_product.tag!(price[0], price[1]) 
    end

    return json_product.compile!
  end

end
