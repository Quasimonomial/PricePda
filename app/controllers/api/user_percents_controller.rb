module Api
  class UserPercentsController < ApiController
    def show
      # @user = User.find(params[:id])
      render json: self.current_user.jsonify_this
    end

    # def update
    #   @product = Product.find(params[:id])
    #   Price.process_product(params, @product, self.current_user)

    #   if @product.update(product_params)
    #     render json: @product.jsonify_this(self.current_user)
    #   else
    #     render json: @product.errors.full_messages, status: :unprocessable_entity
    #   end
    # end

    private
    def user_percent_params
      params.require(:user).permit(:price_range_percentage)
    end
  end
end