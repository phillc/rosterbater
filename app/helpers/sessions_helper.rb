module SessionsHelper
  protected

  def sign_in(user)
    session[:current_user_id] = user.id
  end

  def sign_out
    session[:current_user_id] = @current_user = nil
  end

  def current_user
    @current_user ||= User.where(id: session[:current_user_id]).first
  end
end
