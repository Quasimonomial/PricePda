class StaticPagesController < ApplicationController
  before_action :require_logged_in!
	def root
		@products = Product.all
		@companies = Company.all
		render :root
	end
end