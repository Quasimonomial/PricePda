module Api
  class ProductsController < ApiController
    before_action :require_admin_access!, only: [:create, :destroy]

    def index
      # @products = Product.all
      # if current_user.is_admin
      #   @products = Product.all.order(:id)
      # else
      #   @companies = Company.where(enabled: true).order(:id)
      # end
      render json: JSON.parse(Product.jsonify_all(self.current_user))["products"]
    end
    
    def distinct_categories
      render json: Product.all_categories
    end

    def show
      @product = Product.find(params[:id])
      render json: @product.jsonify_this(self.current_user)
    end

    def update
      @product = Product.find(params[:id])
      Price.process_product(params, @product, self.current_user)
      if current_user.is_admin
        if @product.update(product_params)
          render json: @product.jsonify_this(self.current_user)
        else
          render json: @product.errors.full_messages, status: :unprocessable_entity
        end
      else
        render json: @product.jsonify_this(self.current_user)
      end
    end

    def create
      @product = Product.new(product_params)
      @product.enabled = true
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

    def historical_prices
      @product = Product.find(params[:id])
      render json: @product.graph_hash_full_set(current_user)
    end

    def mass_user_prices
      puts "mass uploading user prices"
      # puts params
      # puts params["prices"]
      Price.update_user_prices_via_table params["prices"], current_user
      render json: {}
    end

    def mass_product_data
      puts "mass uploading user data"
      Product.update_product_data_va_table params["data"]
      render json: {}
    end


    private
    def product_params
      params.require(:product).permit(:category, :name, :dosage, :package, :enabled)
    end
  end
end