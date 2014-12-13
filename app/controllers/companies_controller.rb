class CompaniesController < ApplicationController
  def index
    @companies = Company.all
    render :index
  end

  def show
    @company = Company.find(params[:id])
    render :show
  end

  def new
    @company = Company.new
    render :new
  end

  def edit
    @company = Company.find(params[:id])
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to company_url(@company)
    else
      flash[:errors] = @company.errors.full_messages
      render :new
    end
  end

  def update
    @company = Company.find(params[:id])
    if @company.update(company_params)
      redirect_to company_url
    else
      flash[:errors] = @company.errors.full_messages
      redirect_to company_url
    end 
  end

  def destroy
    @company = find(params[:id])
    @company.destroy!
    redirect_to companies_url
  end

  private
  def company_params
    params.require(:company).permit(:name)
  end
end