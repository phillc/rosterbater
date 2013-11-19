class SessionsController < ApplicationController
  def create_from_omniauth
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.name = auth.extra.raw_info.name
    user.email = auth.info.email
    user.save!

    sign_in user
    redirect_to teams_path
  end
end
