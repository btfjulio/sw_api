class Api::V1::SuplementosController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User

    def index 
      if params[:changed].present?
        @suplementos = Suplemento.where(price_changed: true)
      else
        @suplementos = Suplemento.all
      end
      if params[:query].present?
          query_result = @suplementos.order(:price_cents).sup_search(params[:query])
          @suplementos = query_result.page(params[:page]).per(50)
          total_pages = (query_result.size.to_f / 50).ceil
      else
          @suplementos = @suplementos.page(params[:page]).per(50)
          total_pages = (@suplementos.count.to_f / 50).ceil
      end
      @headers = [{
        total_pages: total_pages
        }]
    end 

end