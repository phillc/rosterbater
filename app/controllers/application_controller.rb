class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit::Authorization

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :verify_authorized

  protected

  def please_log_in(exception)
    if !current_user
      flash[:error] = "Please log in to do that"
      redirect_to root_path
    else
      redirect_to leagues_path
    end
  end
end
