class Api::V2::CategoriesController < Api::V2::BaseController
  acts_as_token_authentication_handler_for User
  before_action :set_suplement, only: [:show]

  def index
    @categories = Category.all
    paginate json: @categories
  end
end
