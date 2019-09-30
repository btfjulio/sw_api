class Api::V1::SuplementosController < Api::V1::BaseController
    def index
      @suplementos = Suplemento.all
    end
  end