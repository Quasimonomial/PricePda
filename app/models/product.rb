# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  category     :string(255)      not null
#  manufacturer :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  name         :string(255)      not null
#  enabled      :boolean          not null
#

class Hash
  def self.recursive
    new { |hash, key| hash[key] = recursive }
  end
end

class Product < ActiveRecord::Base
  validates :category, :name, :manufacturer, presence: true

  has_many :prices
  has_many :historical_prices, through: :prices


  def self.update_product_data_va_table data
    data.each do |product_data|
      product_data = product_data[1]



      product = Product.find(product_data["id"].to_i)
      puts "space cadet" unless product
      product.category = product_data["category"]
      product.name = product_data["name"]
      product.manufacturer = product_data["manufacturer"]

      product.save


      prices = product.prices

      prices_hash = Hash.new #has the prices from our datavase

      company_name_hash = Company.build_name_hash

      prices.each do |price|
        if price.pricer_type == "Company"
          prices_hash[price.pricer_id] = [price.id, price.price]
        end
      end

      set_vars = ["id", "name","category", "manufacturer", "format", "action", "controller", "product"] #hardcode in some things I don't need    
      product_data.each do |key, value|
        next if set_vars.include?(key) || !company_name_hash.include?(key)

        if prices_hash.has_key?(company_name_hash[key])
          price_data = prices_hash[company_name_hash[key]]
          
          unless value == price_data[1]
            price_to_update = Price.find(price_data[0])
            price_to_update.price = value
            price_to_update.save!
            price_to_update.create_historical_price
          end
        else #create new price if we don't jave a real company
          puts "Attempting to load in new price"
          new_price = Price.new({product_id: product_data["id"].to_i, pricer_type: "Company", pricer_id: company_name_hash[key], price: value})
          p new_price
          new_price.save!
          new_price.create_historical_price
        end

      end
    end

  end

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
      product_cells = [product.id, product.category, product.name, product.manufacturer]
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

    headers = ["ID", "Category", "Product", "Manufacturer", "Price"]

    i = 0
    j = 0

    while j < headers.length
      worksheet.add_cell(i, j, headers[j])
      j += 1
    end

    j = 0
    i += 1

    Product.all.where(enabled: true).order(:category).order(:name).order(:manufacturer).each do |product|
      product_cells = [product.id, product.category, product.name, product.manufacturer]
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
      product.manufacturer = product_attrs["Manufacturer"]
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
      json_products.manufacturer product.manufacturer
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
    "November", "December"]

    current_year =  DateTime.now.year
    current_month = month_names[DateTime.now.month]

    years_of_interest = [current_year - 2, current_year - 1, current_year]
    # years_of_interest = [current_year]

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
    #need year -1, year -2
    # need year Q1 - Q4, year - 1  Q1 - Q4


    historical_hash = self.graph_hash_full_user_prices current_user



    month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
    "November", "December"]
    current_month = DateTime.now.month

    current_year =  DateTime.now.year
    
    return historical_hash unless historical_hash[current_year - 2]["January"]["User"].is_a? Numeric


    two_year_back_average = 0
    month_names.first(12).each do |month|
      two_year_back_average += historical_hash[current_year - 2][month]["User"]
    end
    historical_hash[current_year - 2]["Year"]["User"] = two_year_back_average/12.0


    one_year_back_average = 0
    month_names.first(12).each do |month|
      one_year_back_average += historical_hash[current_year - 1][month]["User"]
    end
    historical_hash[current_year - 1]["Year"]["User"] = two_year_back_average/12.0


    one_year_back_q1 = 0
    one_year_back_q2 = 0
    one_year_back_q3 = 0
    one_year_back_q4 = 0

    current_year_q1 = 0
    current_year_q2 = 0
    current_year_q3 = 0
    current_year_q4 = 0


    month_names[0..2].each do |month|
      one_year_back_q1 += historical_hash[current_year - 1][month]["User"]
    end
    month_names[3..5].each do |month|
      one_year_back_q2 += historical_hash[current_year - 1][month]["User"]
    end
    month_names[6..8].each do |month|
      one_year_back_q3 += historical_hash[current_year - 1][month]["User"]
    end
    month_names[9..11].each do |month|
      one_year_back_q4 += historical_hash[current_year - 1][month]["User"]
    end


    historical_hash[current_year - 1]["Quarter 1"]["User"] = one_year_back_q1/3.0
    historical_hash[current_year - 1]["Quarter 2"]["User"] = one_year_back_q2/3.0
    historical_hash[current_year - 1]["Quarter 3"]["User"] = one_year_back_q3/3.0
    historical_hash[current_year - 1]["Quarter 4"]["User"] = one_year_back_q4/3.0


    if current_month > 3
      month_names[0..2].each do |month|
        current_year_q1 += historical_hash[current_year][month]["User"]
      end
      historical_hash[current_year]["Quarter 1"]["User"] = current_year_q1/3.0 
    end

    if current_month > 6
      month_names[3..5].each do |month|
        current_year_q2 += historical_hash[current_year][month]["User"]
      end
      historical_hash[current_year]["Quarter 2"]["User"] = current_year_q2/3.0 

    end

    if current_month > 9
      month_names[6..8].each do |month|
        current_year_q3 += historical_hash[current_year][month]["User"]
      end
      historical_hash[current_year]["Quarter 3"]["User"] = current_year_q3/3.0
    end


    historical_hash
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

    order_array = self.graph_columns_by_month current_month, current_year

    self.prices.where({pricer_type: "Company"}).each do |price|
      price.historical_prices.order(year: :asc).order(month: :asc).order(created_at: :asc).each do|historical_price|
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name] = historical_price.price_value
        historical_hash[historical_price.year][month_names[historical_price.month - 1]][companies.find(price.pricer_id).name]
      end
    end
    historical_hash = historical_hash.deep_merge(self.graph_hash_calculated_user_prices current_user)
    historical_hash["order_array"] = order_array

    historical_hash = ensure_full_order_array historical_hash

    historical_hash
  end


  def jsonify_this current_user #do I ever need to use this?
    json_product = Jsonify::Builder.new(:format => :pretty)
    json_product.id self.id
    json_product.category self.category
    json_product.manufacturer self.manufacturer
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
      next unless price.price > 0
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
    when "January"
      graph_columns = [["Year", year - 2], ["Quarter 1", year - 1], ["Quarter 2", year - 1], ["Quarter 3", year - 1], ["Quarter 4", year - 1], ["January", year]]   
    when "February"
      graph_columns = [["Year", year - 2], ["Quarter 1", year - 1], ["Quarter 2", year - 1], ["Quarter 3", year - 1], ["Quarter 4", year - 1], ["January", year], ["February", year]]
    when "March"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["January", year], ["February", year], ["March", year]]
    when "April"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["January", year], ["February", year], ["March", year], ["April", year]]
    when "May"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["April", year], ["May", year]]
    when "June"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["April", year], ["May", year], ["June", year]]
    when "July"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["April", year], ["May", year], ["June", year], ["July", year]]
    when "August"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["Quarter 2", year], ["July", year], ["August", year]]
    when "September"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["Quarter 2", year], ["July", year], ["August", year], ["September", year]]
    when "October"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["Quarter 2", year], ["Quarter 3", year], ["October", year]]
    when  "November"
      graph_columns = [["Year", year - 2], ["Year", year - 1], ["Quarter 1", year], ["Quarter 2", year], ["Quarter 3", year], ["October", year], ["November", year]]
    when "December"
      graph_columns = [["Year", year - 1], ["Quarter 1", year], ["Quarter 2", year], ["Quarter 3", year], ["October", year], ["November", year], ["December", year]]
    else
      graph_columns = []
    end
    return graph_columns
  end

end
