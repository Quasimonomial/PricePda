class ExcelController < ApplicationController
  def import_products
    puts "IMPORTING A FILE"
    puts params
    puts
    puts params[:sheet].tempfile
    if params[:sheet].tempfile.path
      Product.import_from_excel(params[:sheet].tempfile.path)
    else
      puts "no file selected"
      render json: "No File selected"
    end

    render json: "Products imported"
  end

end