module Api
	class PricesController < ApiController
		# def new
		# 	@products = Product.all
		# 	@companies = Company.all
		# 	@price = Price.new
		# 	render :new
		# end

		#um so we should have any user default the pricer id to that of the current user before we save it
		


		def create
			#definately redo all this

			@price = Price.new(price_params)
			if @price.pricer_id == -1
				@price.pricer_id = current_user.id
				@price.pricer_type = "User"
			end

			if @price.save
			  render json: @price
			else
			  render json: @price.errors.full_messages, status: :unprocessable_entity
			end
		end


		private
		def price_params
			params.require(:price).permit(:price, :product_id, :pricer_id, :pricer_type)
		end
	end
end