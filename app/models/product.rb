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

  def self.export_user_data
    puts "exporting!"
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Users'
    
    headers = ["ID", "Email", "First Name", "Last Name", "Hospital Name", "Hospital Abbreviation", "City", "State", "Zip", "Phone", "Admin", "Activated", "Price Percentage"]

    i = 0
    j = 0

    while j < headers.length
      worksheet.add_cell(i, j, headers[j])
      j += 1
    end            

    User.all.order(:id).each do |product|
      # puts "Writing Product #{product.id}"
      product_cells = [product.id, product.category, product.name, product.dosage, product.package]
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end

    return workbook.stream
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
      # puts "Writing Product #{product.id}"
      product_cells = [product.id, product.category, product.name, product.dosage, product.package]
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end

    # puts workbook.stream
    # workbook.write("public/user_upload.xlsx")
    return workbook.stream
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

  def graph_hash_user_prices current_user #returns a hash of the users prices for the last three years
    current_year =  DateTime.now.year
    
    historical_hash = Hash.recursive
    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December"]
    years_of_interest = [current_year - 2, current_year - 1, current_year]

    user_price = self.prices.where({pricer_type: "User", pricer_id: current_user.id}).first
    return historical_hash unless user_price

    if user_price
      user_price.historical_prices.where(year: years_of_interest[0]..years_of_interest[-1]).order(year: :asc).order(month: :asc).order(created_at: :asc).each do |historical_price|
        historical_hash[historical_price.year][month_names[historical_price.month - 1]]["User"] = historical_price.price_value
      end
    end

    historical_hash
  end

  def graph_hash_full_user_prices current_user

    historical_hash = self.graph_hash_user_prices current_user

    # return historical_hash

    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December"]

    current_year =  DateTime.now.year
    current_month = month_names[DateTime.now.month]

    # years_of_interest = [current_year - 2, current_year - 1, current_year]
    years_of_interest = [current_year]

    user_price = self.prices.where({pricer_type: "User", pricer_id: current_user.id}).first
    return historical_hash unless user_price
    first_price = user_price.historical_prices.where(year: 0...years_of_interest[0]).last 
    last_price = nil

    current_month_year_flag = false

    years_of_interest.each do |year|
      month_names.each do |month|
        break if current_year == year && current_month == month 
        if historical_hash[year][month]["User"].is_a? Numeric
          unless first_price
            first_price = historical_hash[year][month]["User"]

            current_time_flag = false
            years_of_interest.each do |empty_year|
              month_names.each do |empty_month|
                if empty_year == year && empty_month == month
                  current_time_flag = true
                  break
                end
                historical_hash[empty_year][empty_month]["User"] = first_price
              end
              break if current_time_flag
            end
          end
          last_price = historical_hash[year][month]["User"]
        else
          if last_price
            historical_hash[year][month]["User"] = last_price
          end 
        end
      end
      break if current_month_year_flag
    end
    historical_hash
  end

  def graph_hash_calculated_user_prices current_user
    #skip this for beta
  end

  def graph_hash_full_set current_user

    companies = Company.all
    historical_pile = []
    historical_hash = Hash.recursive
    
    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December"]
    current_month = month_names[DateTime.now.month]

    current_year =  DateTime.now.year
    years_of_interest = [current_year - 2, current_year - 1, current_year]


    order_array = []

    years_of_interest.each do |year|
      month_names.each do |month|
        order_array << [month, year]
      end
    end


    self.prices.where({pricer_type: "Company"}).each do |price|
      price.historical_prices.order(year: :asc).order(month: :asc).order(created_at: :asc).each do|historical_price|
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name] = historical_price.price_value
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name]
      end
    end
    historical_hash = historical_hash.deep_merge(self.graph_hash_full_user_prices current_user)
    historical_hash["order_array"] = order_array
    historical_hash
  end


  # def generate_historical_hash_by_yr_quarter
  #   #month 13 is Q1
  #   #      14 is Q2
  #   #      15 is Q3
  #   #      16 is Q4
  #   #      17 is Year

  # end

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
