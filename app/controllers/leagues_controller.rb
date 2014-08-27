class LeaguesController < ApplicationController
  before_action :authenticate_user!, except: :show

  def index
    @leagues = current_user.leagues
  end

  def refresh
    service.refresh_leagues

    redirect_to leagues_path, notice: "Refreshed leagues"
  end

  def show
    @league = League.find(params[:id])
  end

  def sync
    league = current_user.leagues.find(params[:id])
    service.sync_league(league)

    redirect_to league_path(league), notice: "Synced league"
  end

  protected

  def service
    YahooService.new(current_user)
  end
end
