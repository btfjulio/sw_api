class Api::V2::BaseSuplementsController < Api::V2::BaseController
  acts_as_token_authentication_handler_for User
  before_action :set_suplement, only: [:show]

  def index
    @suplements = BaseSuplement.all.first(5)
    render json: @suplements, include: [:sup_photos, :brand]
  end

  def show
    render json: @suplement
  end

  def create
    @suplement = BaseSuplement.new(suplement_params)
    if @suplement.save
      render json: @suplement, status: :created, location: @suplement
    else
      render json: @suplement.errors, status: :unprocessable_entity
    end
  end

  private

  def set_suplement
    @suplement = BaseSuplement.find(params['id'])
  end

end