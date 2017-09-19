class SessionsController < ApplicationController
  skip_after_action :verify_authorized

  def create_from_omniauth
    auth = request.env["omniauth.auth"]

    user = User.where(provider: auth.provider, yahoo_uid: auth.uid).first_or_initialize
    user.name = auth.info.name
    user.yahoo_token = auth.credentials.token
    user.yahoo_refresh_token = auth.credentials.refresh_token
    user.yahoo_expires_at = Time.at(auth.credentials.expires_at)
    user.save!

    sign_in user
    redirect_to leagues_path
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
