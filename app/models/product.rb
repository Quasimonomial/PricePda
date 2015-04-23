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
    worksheet.change_column_width(0, 6)
    worksheet.change_column_width(1, 30)
    worksheet.change_column_width(2, 30)
    worksheet.change_column_width(3, 30)
    worksheet.change_column_width(4, 30)

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

    Product.all.where(enabled: true).order(:category).order(:name).order(:dosage).order(:package).each do |product|
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


  def generate_historical_hash current_user
    companies = Company.all
    historical_pile = []
    historical_hash = Hash.recursive
    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]
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
    "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]
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

    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]

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
    "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]
    current_month = month_names[DateTime.now.month - 1]

    current_year =  DateTime.now.year
    years_of_interest = [current_year - 2, current_year - 1, current_year]

    puts "MONTH #{current_month}, YEAR #{current_year}"

    order_array = self.graph_columns_by_month current_month, current_year

    self.prices.where({pricer_type: "Company"}).each do |price|
      price.historical_prices.order(year: :asc).order(month: :asc).order(created_at: :asc).each do|historical_price|
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name] = historical_price.price_value
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name]
      end
    end
    historical_hash = historical_hash.deep_merge(self.graph_hash_full_user_prices current_user)
    historical_hash["order_array"] = order_array

    historical_hash = ensure_full_order_array historical_hash

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

  def ensure_full_order_array historical_hash
    order_array = historical_hash["order_array"]
    companies = Company.all
    order_array.each do |time|
      month = time[0]
      year = time[1]
      companies.each do |company|
        unless historical_hash[year][month][company.name].is_a? Numeric
          historical_hash[year][month][company.name] = 0 
        end
      end
    end
    p historical_hash        
    return historical_hash
  end

  def graph_columns_by_month month, year
    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]
    
    puts "MONTH IS #{month}"

    case month
    when month_names[1 - 1]
      graph_columns = [[17, year - 2], [13, year - 1], [14, year - 1], [15, year - 1], [16, year - 1], [1, year]]   
    when month_names[2 - 1]
      graph_columns = [[17, year - 2], [13, year - 1], [14, year - 1], [15, year - 1], [16, year - 1], [1, year], [2, year]]
    when month_names[3 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [1, year], [2, year], [3, year]]
    when month_names[4 - 1]
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["January", year], ["February", year], ["March", year], ["April", year]]
    when month_names[5 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [4, year], [5, year]]
    when month_names[6 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [4, year], [5, year], [6, year]]
    when month_names[7 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [4, year], [5, year], [6, year], [7, year]]
    when month_names[8 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [14, year], [7, year], [8, year]]
    when month_names[9 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [14, year], [7, year], [8, year], [9, year]]
    when month_names[10 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [14, year], [15, year], [10, year]]
    when month_names[11 - 1]
      graph_columns = [[17, year - 2], [17, year - 1], [13, year], [14, year], [15, year], [10, year], [11, year]]
    when month_names[12 - 1]
      graph_columns = [[17, year - 1], [13, year], [14, year], [15, year], [10, year], [11, year], [12, year]]
    else
      graph_columns = []
    end
    return graph_columns
  end

end
