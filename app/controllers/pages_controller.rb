class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  
  private

  def send_welcome_email(user)
    UserMailer.with(user: user).welcome.deliver_now
  end

end
