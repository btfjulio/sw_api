class Api::V1::SuplementosController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User

    def index
      if params[:query].present?
          query_result = Suplemento.order(:price_cents).sup_search(params[:query])
          @suplementos = query_result.page(params[:page]).per(50)
          total_pages = (query_result.to_f / 50).ceil
      else
          @suplementos = Suplemento.all.page(params[:page]).per(50)
          total_pages = (Suplemento.count.to_f / 50).ceil
      end
      @headers = [{
        total_pages: total_pages
        }]
    end 

end