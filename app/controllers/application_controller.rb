class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :verify_authorized

  protected

  # def authenticate_user!
  #   redirect_to :root unless current_user
  # end
end
