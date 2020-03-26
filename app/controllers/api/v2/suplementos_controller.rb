class Api::V2::SuplementosController < Api::V2::BaseController
    acts_as_token_authentication_handler_for User

    def index
      @suplementos = Suplemento.all.first(25)
      render json: @suplementos
    end
end
