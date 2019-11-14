class Api::V1::SuplementosController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User

    def index 
      @suplementos = Suplemento.all.order(:price_cents)
      @suplementos = @suplementos.where('price_cents < average').select('price_cents, average').order('price_cents - average') if params[:average].present?
      @suplementos = @suplementos.where(price_changed: true) if params[:changed].present?
      @suplementos = @suplementos.where(supershipping: true) if params[:supershipping].present?
      @suplementos = @suplementos.store_search(params[:store]) if params[:store].present?
      @suplementos = @suplementos.seller_search(params[:seller]) if params[:seller].present?
      @suplementos = @suplementos.name_search(params[:name]) if params[:name].present? 
      total_pages = (@suplementos.count.to_f / 50).ceil
      @suplementos = @suplementos.page(params[:page]).per(50)
      @headers = [{
        total_pages: total_pages
        }]
    end 

end