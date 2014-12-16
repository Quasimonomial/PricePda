class StaticPagesController < ApplicationController
	def root
		@products = Product.all
		@companies = Company.all
		render :root
	end
end