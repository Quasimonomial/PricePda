class ProductsController < ApplicationController
  def index
    @products = Product.all
    render :index
  end

  def show
    @product = Product.find(params[:id])
    render :show
  end

  def update
    @product = Product.find(params[:id])
    unless @product.update(product_params)
      flash[:errors] = @product.errors.full_messages
    end
    redirect_to product_url(@product)
  end

  def new
    render :new
  end

  def edit 
    @product = Product.find(params[:id])
    render :edit
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to product_url(@product)
    else
      flash[:errors] = @product.errors.full_messages
      redirect_to new_product_url
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_url
  end

  private
  def product_params
    params.require(:product).permit(:category, :product, :dosage, :package)
  end
end

#  category   :string(255)
#  product    :string(255)
#  dosage     :string(255)
#  package    :string(255)
