# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  category   :string(255)      not null
#  dosage     :string(255)
#  package    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)      not null
#  enabled    :boolean          not null
#

class Hash
  def self.recursive
    new { |hash, key| hash[key] = recursive }
  end
end

class Product < ActiveRecord::Base
  validates :category, :name, :dosage, presence: true
  validates :category, uniqueness: {scope: [:name, :dosage, :package]}
  has_many :prices
  has_many :historical_prices, through: :prices

  def self.all_categories
    category_relation = Product.select(:category).distinct
    categories = []
    category_relation.each do |product|
      categories << product.category
    end
    categories
  end

  def self.export_user_price_uploads
    puts "exporting!"
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'User Uploads'

    puts "Wroksheet test"
    puts  worksheet

    headers = ["ID", "Category", "Product", "Dosage", "Package", "Price"]

    i = 0
    j = 0

    while j < headers.length
      worksheet.add_cell(i, j, headers[j])
      j += 1
    end

    j = 0
    i += 1

    Product.all.each do |product|
      puts "Writing Product #{product.id}"
      product_cells = [product.id, product.category, product.name, product.dosage, product.package]
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end

    # puts workbook.stream
    workbook.write("public/user_upload.xlsx")
    # return workbook.stream
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
      product.enabled = true
      product.save!
    end
  end

  def self.jsonify_all current_user
    if current_user.is_admin
      @products = Product.all.order(:id)
    else
      @products = Product.where(enabled: true).order(:id)
    end

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

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def generate_historical_hash current_user
    companies = Company.all
    historical_pile = []
    historical_hash = Hash.recursive
    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December"]
    self.prices.where({pricer_type: "Company"}).each do |price|
      price.historical_prices.order(year: :asc).order(month: :asc).order(created_at: :asc).each do|historical_price|
        next unless historical_price.month && historical_price.year
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name] = historical_price.price_value
      end
    end
    user_price = self.prices.where({pricer_type: "User", pricer_id: current_user.id}).first
    if user_price
      user_price.historical_prices.order(year: :asc).order(month: :asc).order(created_at: :asc).each do |historical_price|
        next unless historical_price.month && historical_price.year
        historical_hash[historical_price.year][month_names[historical_price.month - 1]]["User"] = historical_price.price_value
      end
    end

    historical_hash
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

  def prices_array current_user
    @pricesArray = []
    @pricesForProduct = self.prices.includes(:pricer)

    @pricesForProduct.each do |price|
      next if price.pricer.nil?
      if price.pricer_type == "Company"
        @pricesArray << [price.pricer.name, price.price]
      elsif price.pricer_type == "User" && price.pricer_id == current_user.id
        @pricesArray << ["User", price.price]
      end
    end
    return @pricesArray
  end

end
