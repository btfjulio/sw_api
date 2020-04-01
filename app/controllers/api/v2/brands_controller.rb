class Api::V2::BrandsController < Api::V2::BaseController
  acts_as_token_authentication_handler_for User
  before_action :set_suplement, only: [:show]

  def index
    @brands = Brand.page(params[:page]).per(15)
    paginate json: @brands
  end
end
