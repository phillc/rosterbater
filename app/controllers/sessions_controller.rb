class SessionsController < ApplicationController
  def create_from_omniauth
    auth = request.env["omniauth.auth"]

    user = User.where(provider: auth.provider, yahoo_uid: auth.uid).first_or_initialize
    user.name = auth.extra.raw_info.name
    user.email = auth.info.email
    user.yahoo_token = auth.extra.access_token.token
    user.yahoo_token_secret = auth.extra.access_token.secret
    user.yahoo_session_handle = auth.extra.access_token.params[:oauth_session_handle]
    user.save!

    sign_in user
    redirect_to leagues_path
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
