module Api
  class ProductsController < ApiController
    def index
      @products = Product.all
      #render json: @products
      render json: Product.jsonify_all
    end

    def show
      @product = Product.find(params[:id])
      #render json: @product
      render json: @product.jsonify_this
    end

    def update
      @product = Product.find(params[:id])
      Price.process_product(params, @product)
      # puts "testing"
      # puts params
      # puts params.to_h
      # puts "done testing"
      if @product.update(product_params)
        render json: @product.jsonify_this
      else
        render json: @product.errors.full_messages, status: :unprocessable_entity
      end
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        render json: @product
      else
        render json: @product.errors.full_messages, status: :unprocessable_entity
      end
    end

    def destroy
      @product = Product.find(params[:id])
      @product.destroy
      render json: @product
    end

    private
    def product_params
      params.require(:product).permit(:category, :name, :dosage, :package)
    end
  end
end