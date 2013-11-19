class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def sign_in(user)
    session[:current_user_id] = user.id
  end

  def current_user
    User.where(id: session[:current_user_id]).first
  end

  def authenticate_user!
    redirect_to :root unless current_user
  end
end
