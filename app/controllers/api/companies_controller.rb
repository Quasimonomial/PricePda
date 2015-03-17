module Api
  class CompaniesController < ApiController
    before_action :require_admin_access!, only: [:create, :update, :destroy]

    def index
      if current_user.is_admin
        @companies = Company.all.order(:id)
      else
        @companies = Company.where(enabled: true).order(:id)
      end
      render json: @companies
    end

    def show
      @company = Company.find(params[:id])
      render json: @company
    end

    def create
      @company = Company.new(company_params)
      @company.enabled = true
      if @company.save
        render json: @company
      else
        render json: @company.errors.full_messages, status: :unprocessable_entity
      end
    end

    def update
      @company = Company.find(params[:id])
      if @company.update(company_params)
        render json: @company
      else
        render json: @company.errors.full_messages, status: :unprocessable_entity
      end 
    end

    def destroy
      @company = Company.find(params[:id])
      @company.try(:destroy)
      render json: @company
    end

    private
    def company_params
      params.require(:company).permit(:name, :enabled)
    end
  end
end