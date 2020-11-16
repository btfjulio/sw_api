class EquipmentsController < SuplementosController
    layout 'suplementos_layout'
    before_action :get_equip_filters, only: [:index]
    before_action :get_equip_sellers, only: [:index]


    def index 
      @equipments = Equipment.select('*, ((price - average) / (average / 100)) as discount').where('average > 0')
      apply_filters(params[:filters])
      @equipments = @equipments.where(store_id: params[:store]) if params[:store].present?
      @equipments = @equipments.seller_search(params[:seller]) if params[:seller].present?
      @equipments = @equipments.name_search(params[:name]) if params[:name].present?
      @equipments = @equipments.page(params[:page]).per(28)
    end

    def create_bitlink
        client = Bitly.client
        @equipment = params[:equipment]
        @link = params[:link]
        @link = client.shorten(@link).short_url
    end

    def get_equip_sellers
      @equip_sellers = Equipment.order(:seller).pluck(:seller).uniq
    end

    def get_equip_filters
        @equip_filters = ['average','combo', 'frete', 'cupom', 'preço']
    end
  
    def apply_filters(filters)
        if filters
            @equipments = @equipments.order(price: :asc) if (filters.include?("price") || !filters.include?("average"))
            @equipments = @equipments.where('price < average').order('discount') if filters.include?("average")
            @equipments = @equipments.where("promo <> ''") if filters.include?("cupom")
            @equipments = @equipments.where(free_shipping: true) if filters.include?("frete")
            @equipments = @equipments.where(combo: "true") if filters.include?("combo")
        else
            @equipments = @equipments.order(price: :asc)
        end    
    end
    
end
