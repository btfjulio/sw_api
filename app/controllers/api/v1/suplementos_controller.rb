class Api::V1::SuplementosController < Api::V1::BaseController
  before_action :set_store, only: :index
  acts_as_token_authentication_handler_for User

    def index
      if params[:query].present?
          @suplementos = Suplemento.order(:price_cents).sup_search(params[:query]).page(params[:page]).per(50)
      else
          @suplementos = Suplemento.all.page(params[:page]).per(50)
      end
    end

    private

    def set_store
      @store = Store.find(params[:store_id])
    end

end