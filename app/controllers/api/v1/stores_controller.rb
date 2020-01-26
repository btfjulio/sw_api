class Api::V1::StoresController < Api::V1::BaseController
    acts_as_token_authentication_handler_for User
  
      def index 
        @stores = Store.all
        @sellers = Suplemento.all.select(:seller).group('seller')
      end 

      def show
        store = Store.find(params[:id])
        @sellers = store.suplementos.select(:seller).group('seller')
      end

  
  end