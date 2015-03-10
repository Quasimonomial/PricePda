module Api
  class ProductsController < ApiController
    before_action :require_admin_access!, only: [:create, :destroy]

    def index
      @products = Product.all
      #render json: @products
      respond_to do |format|
        format.json {render json: Product.jsonify_all(self.current_user)}
        format.html {render json: Product.jsonify_all(self.current_user)}
        format.csv { send_data @products.to_csv}
        format.xlsx
      end
    end

    def show
      @product = Product.find(params[:id])
      #render json: @product
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
      puts "Fetching Historicals"
      puts @product.generate_historical_hash
      render json: @product.generate_historical_hash
    end

    private
    def product_params
      params.require(:product).permit(:category, :name, :dosage, :package, :enabled)
    end
  end
end