class ExcelController < ApplicationController
  before_action :require_admin_access!, only: [:import_company_prices, :import_products]
  
  def import_company_prices
    if params[:sheet]
      Price.import_company_from_excel(params[:sheet].tempfile.path, params[:month], params[:year])
    end

    render json: "Prices imported"
  end

  def import_products
    if params[:sheet].tempfile.path
      Product.import_from_excel(params[:sheet].tempfile.path)
    else
      puts "no file selected"
      render json: "No File selected"
    end

    render json: "Products imported"
  end

  def export_user_data
    send_data Price.export_user_data(2015).read
  end

  def export_user_uploads
    send_data Product.export_user_price_uploads.read
  end

  def upload_user_prices
    if params[:sheet].tempfile.path
      Price.import_user_from_excel(params[:sheet].tempfile.path, current_user)
    else
      puts "no file selected"
      render json: "No File selected"
    end

    render json: "prices imported"
  end

  def seeded_products
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Sample Products'

    headers = ["ID", "Category", "Product", "Manufacturer", "Price"]

    i = 0
    j = 0

    while j < headers.length
      worksheet.add_cell(i, j, headers[j])
      j += 1
    end

    j = 0
    i += 1

    manufacturers = []

    (1..10).each do |manufacturer|
      manufacturers.push(Faker::Company.name)
    end



    (1..150).each do |product|
      if product <  44
        category = "red"
      elsif product < 106
        category = "blue"
      else
        category = "green"
      end

      product_cells = [product, category, Faker::Commerce.product_name, manufacturers[rand(0..9)]]
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end

    send_data workbook.stream.read
  end

  def seeded_user_uploads

    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'User Uploads'
    worksheet.change_column_width(0, 6)
    worksheet.change_column_width(1, 30)
    worksheet.change_column_width(2, 30)
    worksheet.change_column_width(3, 30)
    worksheet.change_column_width(4, 30)

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
      price = rand(0..9999)/100.0
      product_cells.push(price + price * rand(-10..10)/100.0)
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end
    send_data workbook.stream.read

  end

  def seeded_price_uploads
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Mass Price Uplods Uploads'

    headers = ["ID", "Category", "Product", "Manufacturer"]
    
    Company.all.each do |company|
      headers << company.name
    end



    i = 0
    j = 0

    while j < headers.length
      worksheet.add_cell(i, j, headers[j])
      j += 1
    end

    j = 0
    i += 1

    Product.all.each do |product|
      product_cells = []
      product_cells.push(product.id)
      product_cells.push(product.category)
      product_cells.push(product.name)
      product_cells.push(product.manufacturer)      

      
      price = rand(0..9999)/100.0 
      while product_cells.length < headers.length
        product_cells.push(price + price * rand(-10..10)/100.0)
      end
      while j <  product_cells.length
        worksheet.add_cell(i, j, product_cells[j])
        j += 1
      end
      j = 0
      i += 1
    end

    send_data workbook.stream.read

  end

end