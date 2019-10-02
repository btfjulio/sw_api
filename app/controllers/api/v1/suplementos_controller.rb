class Api::V1::SuplementosController < Api::V1::BaseController
  before_action :set_store, only: :index
    def index
      @suplementos = Suplemento.where(store: @store)
    end

    private

    def set_store
      @store = Store.find(params[:store_id])
    end

end