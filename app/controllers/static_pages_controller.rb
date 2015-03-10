class StaticPagesController < ApplicationController
  before_action :require_logged_in!
	
  def root
    puts "Hello to root from rails"
		@products = Product.all
		@companies = Company.all
		render :root
	end
end