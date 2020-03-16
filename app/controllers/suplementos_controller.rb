class SuplementosController < ApplicationController

    def index 
      @suplementos = Suplemento.all
      apply_filters(params[:filters]) unless params[:filters].empty
      @suplementos = @suplementos.order(:price_cents) unless params[:average].present?
      @suplementos = @suplementos.where(store_id: params[:store]) if params[:store].present?
      @suplementos = @suplementos.seller_search(params[:seller]) if params[:seller].present?
      @suplementos = @suplementos.name_search(params[:name]) if params[:name].present?
      @suplementos = @suplementos.page(params[:page]).per(50)
      @sellers = Suplemento.pluck(:seller).uniq
      @stores = Store.all
      @filters = get_filters()
    end
    
    def create_bitlink
        client = Bitly.client
        @suplemento = params[:suplemento]
        @link = params[:link]
        choice = params[:choice]&.first
        @link = change_cupom(@link, params[:cupom]) if params[:cupom].present?
        @link = @link.gsub('lojacorpoperfeito', choice) if choice.present?
        @link = client.shorten(@link).short_url
    end
    
    def change_cupom(link, cupom)
        case link.match(/(?<=(www).)(.*)(?=\.com)/)[2] 
        when "lojacorpoperfeito"
            @link.gsub(/vp=.+/, "vp=#{cupom}")
        when "netshoes"
            @link.gsub(/(?<=(campaign).)(.*)(?=\])/, "#{cupom}")
        else
            @link
        end
    end
    
    private
    
    def apply_filters(filters)
        @suplementos = Suplemento.where('price_cents < average').order('price_cents < average') if filters.include?("average")
        @suplementos = @suplementos.where.not(promo: '') if filters.include?("promo")
        @suplementos = @suplementos.where(supershipping: true) if filters.include?("supershipping")
        @suplementos = @suplementos.where(combo: true) if filters.include?("combo")    
    end

    def get_filters
        ['combo', 'supershipping', 'average', 'promo']
    end
end
