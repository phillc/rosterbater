class InfosController < ApplicationController
  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path
  end

  def show
    authorize :info, :show?

    @user_count = User.count
    # Maybe group by create date?

    @league_count = League.count
  end
end
