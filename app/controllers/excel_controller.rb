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
    send_data Product.export_user_data.read
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
end