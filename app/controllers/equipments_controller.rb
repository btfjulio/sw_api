class EquipmentsController < SuplementosController
    layout 'suplementos_layout'
    # before_action :get_stores, only: [:index]
    # before_action :get_filters, only: [:index]
    # before_action :get_sellers, only: [:index]


    def index 
      @equipments = Equipment.all
      @equipments = @equipments.page(params[:page]).per(28)
    end
end
