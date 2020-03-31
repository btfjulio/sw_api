class PostsController < SuplementosController
    layout 'suplementos_layout'
    before_action :get_stores, only: [:index]
    before_action :get_filters, only: [:index]
    before_action :get_sellers, only: [:index]
    
    def index
        @posts = Post.all.includes(sup_posts: :suplemento).order(clicks: :desc)
        raise
    end
end
