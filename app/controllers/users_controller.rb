class UsersController < ApplicationController
  before_action :demand_not_logged_in, only: [:new]

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
    @user.price_range_percentage = 10
    @user.is_admin = false
    @user.permission_level = 0 #users by default are not allowed to access anything - anything asking for permission will have a permission level OR an is_admin cluase so admins can always do whatever they want
    if @user.save
      UserMailer.account_activation(@user).deliver
      flash[:info] = "Please check your email to activate your account."
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
    params.require(:user).permit(:email, :password, :price_range_percentage, :first_name, :last_name, :hospital_name, :city, :state, :zip_code, :phone, :abbreviation)
  end
end