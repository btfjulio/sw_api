class PostsController < SuplementosController
    layout 'suplementos_layout'
    before_action :get_stores, only: [:index]
    before_action :get_filters, only: [:index]
    before_action :get_sellers, only: [:index]
    
    def index
        @posts = Post.all.order(clicks: :desc)
    end
end
