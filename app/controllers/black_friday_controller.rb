class BlackFridayController < SuplementosController
  skip_before_action :authenticate_user!

  layout "application"

  def index 
    @posts = Post.all
  end

end