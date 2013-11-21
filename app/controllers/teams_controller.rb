class TeamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @teams = current_user.teams
  end

  def refresh
    service.refresh_teams

    redirect_to teams_path
  end

  protected

  def service
    YahooService.new(current_user)
  end
end
