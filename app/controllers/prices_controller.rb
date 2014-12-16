class PricesController < ApplicationController
	def new
		@products = Product.all
		@companies = Company.all
		@price = Price.new
		render :new
	end


	def create
		@price = Price.new(price_params)
		if @price.pricer_id == -1
			@price.pricer_id = current_user.id
			@price.pricer_type = "User"
		end

		if @price.save
		  redirect_to root_url
		else
		  flash[:errors] = @price.errors.full_messages
		  render :new
		end
	end


	private
	def price_params
		params.require(:price).permit(:price, :product_id, :pricer_id, :pricer_type)
	end
end
