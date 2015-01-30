module Api
  class UserPercentsController < ApiController
    def show
      # @user = User.find(params[:id])
      render json: self.current_user.jsonify_this
    end

    def create
      @user = self.current_user

      if @user.update(user_params)
        render json: @user.jsonify_this
      else
        render json: @user.errors.full_messages, status: :unprocessable_entity
      end
    end

    private
    def user_params
      params.require(:user_percent).permit(:price_range_percentage)
    end
  end
end