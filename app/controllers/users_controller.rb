class UsersController < ApplicationController
  def new
    @user = User.new
    render :new
  end

  def edit
    @user = current_user
    render :edit
  end

  def create
    @user = User.new(user_params)
    User.price_range_percentage = 10
    if @user.save
      log_in!(@user)
      redirect_to root_url
    else
      flash[:errors] = @user.errors.full_messages
      render :new
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to root_url
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to root_url
    end
  end


  private
  def user_params
    params.require(:user).permit(:email, :password, :price_range_percentage)
  end
end