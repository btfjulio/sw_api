class Api::V1::StoresController < Api::V1::BaseController
    acts_as_token_authentication_handler_for User
  
      def index 
        @stores = Store.all
      end 

      def show
        store = Store.find(params[:id])
        @coupons = store.suplementos.select(:seller).group('seller')
      end

  
  end