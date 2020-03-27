class Api::V2::SuplementosController < Api::V2::BaseController
  acts_as_token_authentication_handler_for User
  before_action :set_suplemento, only: [:show]

  def index
    @suplementos = Suplemento.all.first(25)
    render json: @suplementos
  end

  def show
    render json: @suplemento, methods: :prices_collection
  end

  def create
    @suplemento = Suplemento.new(suplemento_params)
    if @suplemento.save
      render json: @suplemento, status: :created, location: @suplemento
    else
      render json: @suplemento.errors, status: :unprocessable_entity
    end
  end

  private

  def set_suplemento
    @suplemento = Suplemento.find(params[:id])
  end

end
